resource "aws_lambda_function" "ec2_status_check_recovery" {
  function_name = var.lambda_function_name
  filename      = var.output_path
  role          = var.role_for_lambda_status_check_arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  description   = var.description

  environment {
    variables = {
      sns_topic_name = var.sns_topic_for_support_notification
    }
  }
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_event_rule" "instance_state_change" {
  name        = "capture-instance-state-change"
  description = "Capture EC2 instance state change"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "EC2 Instance State-change Notification"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.instance_state_change.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.instance_state_change_sns_topic.arn
}

resource "aws_sns_topic" "instance_state_change_sns_topic" {
  name = "instance-state-change-sns-topic"
}

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.instance_state_change_sns_topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

resource "aws_sns_topic_subscription" "lambda_target" {
  topic_arn = aws_sns_topic.instance_state_change_sns_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.ec2_status_check_recovery.arn
}

resource "aws_sns_topic" "instance_recovery_notifications_topic" {
  name = var.sns_topic_for_support_notification
}

resource "random_id" "random" {
  byte_length = 8
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = random_id.random.hex
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_status_check_recovery.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.instance_state_change_sns_topic.arn
}

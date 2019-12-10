data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = var.source_code_path
  output_path = var.output_path
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    resources = [aws_sns_topic.instance_state_change_sns_topic.arn]
  }
}

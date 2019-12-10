resource "aws_iam_role" "role_for_lambda_status_check" {
  name               = "role_for_lambda_status_check"
  assume_role_policy = data.aws_iam_policy_document.lambdaExecutionRolePolicy.json
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambdaLoggingPolicy.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.role_for_lambda_status_check.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}


resource "aws_iam_policy" "lambda_manage_alarms" {
  name        = "lambda_manage_alarms"
  path        = "/"
  description = "IAM policy for creating/removing CloudWatch alarms by a lambda"
  policy      = data.aws_iam_policy_document.lambdaManageAlarmsPolicy.json
}

resource "aws_iam_role_policy_attachment" "lambda_manage_alarms_attach" {
  role       = aws_iam_role.role_for_lambda_status_check.name
  policy_arn = aws_iam_policy.lambda_manage_alarms.arn
}

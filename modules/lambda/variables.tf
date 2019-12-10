variable "description" {
  type        = string
  description = "Lambda function description"
  default     = "Lambda function for creating/deleting CloudWatch alarm when an instance starts/stops"
}

variable "lambda_function_name" {
  type        = string
  description = "A unique name for your Lambda Function"
  default     = "ec2_status_check_recovery"
}

variable "handler" {
  type        = string
  description = "The function entrypoint in your code"
  default     = "lambda_function.lambda_handler"
}

variable "runtime" {
  type        = string
  description = "runtime, e.g. python3.7"
  default     = "python3.7"
}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds"
  default     = "10"
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime."
  default     = "128"
}

variable "source_code_path" {
  description = "Path to the source file or directory containing your Lambda source code"
  default     = "./lambda_function.py"
}

variable "output_path" {
  description = "Path to the function's deployment package within local filesystem. eg: /path/to/lambda.zip"
  default     = "lambda.zip"
}

variable "sns_topic_for_instance_state_change" {
  default = "ec2_instance_state_changed"
}

variable "sns_topic_for_support_notification" {
  description = "The topic will be used for cloudwatch alarm"
  default     = "notification_for_instance_recovery"
}

variable "role_for_lambda_status_check_arn" {}

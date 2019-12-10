module "iam_for_lambda" {
  source = "./modules/lambda/iam"
  providers = {
    aws = aws.us-east-1
  }
}

module "ec2_status_check_lambda_us_east_1" {
  source                           = "./modules/lambda"
  role_for_lambda_status_check_arn = module.iam_for_lambda.role_for_lambda_status_check_arn
  providers = {
    aws = aws.us-east-1
  }
}

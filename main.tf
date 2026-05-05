module "validate_transaction" {
  source        = "./modules/lambda_function"
  function_name = "${var.project_name}-validate-transaction-${var.environment}"
  source_dir    = "${path.module}/lambdas/validate_transaction"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  role_arn      = aws_iam_role.lambda_exec.arn
  environment_variables = {}
}

module "risk_assess" {
  source        = "./modules/lambda_function"
  function_name = "${var.project_name}-risk-assess-${var.environment}"
  source_dir    = "${path.module}/lambdas/risk_assess"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  role_arn      = aws_iam_role.lambda_exec.arn
  environment_variables = {}
}

module "route_transaction" {
  source        = "./modules/lambda_function"
  function_name = "${var.project_name}-route-transaction-${var.environment}"
  source_dir    = "${path.module}/lambdas/route_transaction"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  role_arn      = aws_iam_role.lambda_exec.arn
  environment_variables = {
    BUCKET_NAME = aws_s3_bucket.results.bucket
  }
}

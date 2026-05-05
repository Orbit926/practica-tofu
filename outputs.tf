output "s3_bucket_name" {
  description = "Name of the S3 bucket that stores transaction results"
  value       = aws_s3_bucket.results.bucket
}

output "state_machine_arn" {
  description = "ARN of the banking transaction processor Step Function"
  value       = aws_sfn_state_machine.banking_processor.arn
}

output "lambda_validate_transaction_name" {
  description = "Name of the ValidateTransaction Lambda"
  value       = module.validate_transaction.lambda_name
}

output "lambda_risk_assess_name" {
  description = "Name of the RiskAssess Lambda"
  value       = module.risk_assess.lambda_name
}

output "lambda_route_transaction_name" {
  description = "Name of the RouteTransaction Lambda"
  value       = module.route_transaction.lambda_name
}

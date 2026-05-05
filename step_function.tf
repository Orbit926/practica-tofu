resource "aws_sfn_state_machine" "banking_processor" {
  name     = "${var.project_name}-${var.environment}"
  role_arn = aws_iam_role.sfn_exec.arn

  definition = jsonencode({
    Comment = "Banking transaction anti-fraud pipeline"
    StartAt = "ValidateTransaction"
    States = {
      ValidateTransaction = {
        Type     = "Task"
        Resource = module.validate_transaction.lambda_arn
        Next     = "RiskAssess"
      }
      RiskAssess = {
        Type     = "Task"
        Resource = module.risk_assess.lambda_arn
        Next     = "RouteTransaction"
      }
      RouteTransaction = {
        Type     = "Task"
        Resource = module.route_transaction.lambda_arn
        Next     = "RouteChoice"
      }
      RouteChoice = {
        Type = "Choice"
        Choices = [
          {
            Variable      = "$.route"
            StringEquals  = "approved"
            Next          = "Approved"
          },
          {
            Variable      = "$.route"
            StringEquals  = "review"
            Next          = "ManualReview"
          }
        ]
        Default = "InvalidTransaction"
      }
      Approved = {
        Type = "Succeed"
      }
      ManualReview = {
        Type = "Succeed"
      }
      InvalidTransaction = {
        Type    = "Fail"
        Error   = "InvalidTransaction"
        Cause   = "Transaction failed validation or could not be routed"
      }
    }
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

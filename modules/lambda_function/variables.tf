variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "source_dir" {
  description = "Absolute path to the directory containing the Lambda source code"
  type        = string
}

variable "handler" {
  description = "Lambda handler in the format file.function"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime identifier"
  type        = string
  default     = "python3.12"
}

variable "role_arn" {
  description = "ARN of the IAM role attached to the Lambda"
  type        = string
}

variable "environment_variables" {
  description = "Map of environment variables to pass to the Lambda"
  type        = map(string)
  default     = {}
}

variable "timeout" {
  description = "Lambda execution timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Amount of memory allocated to the Lambda in MB"
  type        = number
  default     = 128
}

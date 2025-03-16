variable "s3_bucket_name" {
  description = "The name of the S3 bucket for storing reviews"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "The ARN of the Lambda function to invoke"
  type        = string
}


variable "lambda_function_arn" {
  description = "The ARN of the Lambda function for S3 event notifications"
  type        = string
}



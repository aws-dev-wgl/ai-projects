output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.review_lambda.function_name
}

output "lambda_invoke_arn" {
  description = "The ARN to invoke the Lambda function"
  value       = aws_lambda_function.review_lambda.invoke_arn
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.review_lambda.arn
}


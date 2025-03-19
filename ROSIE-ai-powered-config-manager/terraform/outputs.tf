output "dynamodb_table_name" {
  description = "The name of the DynamoDB table used for software inventory"
  value       = aws_dynamodb_table.software_inventory.name
}

output "lambda_function_name" {
  description = "The name of the Lambda function for software scanning"
  value       = aws_lambda_function.software_scan.function_name
}

output "api_gateway_url" {
  description = "The URL endpoint of the API Gateway"
  value       = aws_api_gateway_stage.rosie_api_stage.invoke_url
}

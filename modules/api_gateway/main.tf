resource "aws_api_gateway_rest_api" "ai_api" {
  name        = "AI Review Summarization API"
  description = "API for summarizing movie critic reviews"
}

resource "aws_api_gateway_resource" "ai_summarize" {
  rest_api_id = aws_api_gateway_rest_api.ai_api.id
  parent_id   = aws_api_gateway_rest_api.ai_api.root_resource_id
  path_part   = "summarize"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.ai_api.id
  resource_id   = aws_api_gateway_resource.ai_summarize.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.ai_api.id
  resource_id = aws_api_gateway_resource.ai_summarize.id
  http_method = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

# ✅ API Deployment (Fix missing reference)
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.ai_api.id
  stage_name  = "prod"
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "ReviewSummarizerAPI"
  description = "API Gateway for AI-powered text summarization"
}

resource "aws_api_gateway_resource" "retrieve_summary" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "retrieve_summary"
}

resource "aws_api_gateway_method" "retrieve_summary" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.retrieve_summary.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "retrieve_summary" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.retrieve_summary.id
  http_method             = aws_api_gateway_method.retrieve_summary.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn  # Use passed variable
}

resource "aws_lambda_permission" "api_gateway_invoke_retrieve" {
  statement_id  = "AllowAPIGatewayInvokeRetrieve"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_api_gateway_rest_api.api.execution_arn
}



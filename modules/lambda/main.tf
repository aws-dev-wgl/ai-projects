resource "aws_lambda_function" "review_lambda" {
  function_name = "ReviewLambda"
  role          = var.iam_role_arn  # Use the IAM role passed from main.tf
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename          = "lambda_function.zip"
  #source_code_hash  = filebase64sha256("lambda_function.zip")

  memory_size = 3000
  timeout     = 360
}

resource "aws_lambda_permission" "api_gateway_invoke_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.review_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:us-east-1:573191494210:nz0gbrk4fl/*/POST/summarize"
}

resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.review_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn  # ✅ Pass as a variable instead of module reference
}







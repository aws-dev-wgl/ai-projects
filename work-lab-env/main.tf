provider "aws" {
  region = "us-east-1"
}

# Create an S3 bucket
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "work-dev-lab-aws-dev-wgl"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_s3_github_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM Policy for Lambda
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_s3_github_policy"
  description = "Allow Lambda to read from S3 and log to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.lambda_bucket.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "lambda_attach" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

# Lambda Function with Environment Variables
resource "aws_lambda_function" "s3_to_github_lambda" {
  function_name = "s3_to_github_lambda"
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"

  role          = aws_iam_role.lambda_role.arn
  filename      = "lambda.zip"  # Must be created before `terraform apply`
  source_code_hash = filebase64sha256("lambda.zip")

  # Environment Variables for GitHub Credentials
  environment {
    variables = {
      GITHUB_TOKEN     = var.github_token
      GITHUB_REPO      = var.github_repo
      GITHUB_BRANCH    = var.github_branch
      GITHUB_FILE_PATH = var.github_file_path
    }
  }
}

# S3 Event Notification (Triggers Lambda on Upload)
resource "aws_s3_bucket_notification" "s3_trigger" {
  bucket = aws_s3_bucket.lambda_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_to_github_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

# Allow S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_to_github_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.lambda_bucket.arn
}

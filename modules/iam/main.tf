resource "aws_iam_role" "lambda_execution_role" {
  name = "LambdaExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "bedrock_full_access" {
  name       = "AttachBedrockPolicy"
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
  roles      = [aws_iam_role.lambda_execution_role.name]
}

resource "aws_iam_policy_attachment" "s3_full_access" {
  name       = "AttachS3Policy"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  roles      = [aws_iam_role.lambda_execution_role.name]
}

resource "aws_iam_policy_attachment" "sagemaker_full_access" {
  name       = "AttachSageMakerPolicy"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
  roles      = [aws_iam_role.lambda_execution_role.name]
}

resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "AttachLambdaBasicExecutionPolicy"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles      = [aws_iam_role.lambda_execution_role.name]
}

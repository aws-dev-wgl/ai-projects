resource "aws_dynamodb_table" "software_inventory" {
  name         = "software-inventory"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "instance_id"
    type = "S"
  }
  attribute {
    name = "software_name"
    type = "S"
  }
  hash_key  = "instance_id"
  range_key = "software_name"
}

resource "aws_iam_role" "lambda_role" {
  name = "rosie_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "rosie_lambda_policy"
  description = "Policy for Lambda to access SSM, DynamoDB, and logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.software_inventory.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:DescribeInstanceInformation",
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      }
    ]
  })
}



resource "aws_iam_policy_attachment" "lambda_dynamodb" {
  name       = "lambda_dynamodb_policy"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_lambda_function" "software_scan" {
  function_name    = "software_scan"
  runtime         = "python3.9"
  role            = aws_iam_role.lambda_role.arn
  handler         = "software_scan.lambda_handler"
  s3_bucket       = aws_s3_bucket.lambda_bucket.bucket
  s3_key          = "software_scan.zip"
  timeout         = 60

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.software_inventory.name
    }
  }
}


resource "aws_api_gateway_rest_api" "rosie_api" {
  name        = "RosieAPI"
  description = "API for querying software versions"
}

resource "aws_api_gateway_resource" "software" {
  rest_api_id = aws_api_gateway_rest_api.rosie_api.id
  parent_id   = aws_api_gateway_rest_api.rosie_api.root_resource_id
  path_part   = "software"
}

resource "aws_api_gateway_method" "get_software" {
  rest_api_id   = aws_api_gateway_rest_api.rosie_api.id
  resource_id   = aws_api_gateway_resource.software.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_deployment" "rosie_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rosie_api.id
  depends_on  = [aws_api_gateway_integration.lambda_integration]

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rosie_api))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "rosie_api_stage" {
  deployment_id = aws_api_gateway_deployment.rosie_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rosie_api.id
  stage_name    = "prod"
}


resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.rosie_api.id
  resource_id = aws_api_gateway_resource.software.id
  http_method = aws_api_gateway_method.get_software.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.software_scan.invoke_arn
}

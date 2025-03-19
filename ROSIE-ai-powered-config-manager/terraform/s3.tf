resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "rosie-lambda-code-bucket"
  acl    = "private"
  force_destroy = true  # Destroys bucket when running `terraform destroy`

  tags = {
    Name        = "RosieLambdaBucket"
    Environment = var.environment
  }
}

# ✅ Call Storage Module (S3)
#module "s3" {
# source = "./modules/s3"
#}

module "iam" {
  source = "./modules/iam"
}

module "lambda" {
  source        = "./modules/lambda"
  iam_role_arn  = module.iam.lambda_role_arn
  s3_bucket_arn = module.s3.review_data_bucket_arn # ✅ Now correctly referencing the output
}

module "s3" {
  source            = "./modules/s3"
  s3_bucket_name    = "my-terraform-state-aws-ai-dev-wgl"
  lambda_invoke_arn = module.lambda.lambda_invoke_arn  # ✅ Ensure this is passed
  lambda_function_arn = module.lambda.lambda_function_arn
}

resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowS3Invoke-${uuid()}"  # ✅ Generates a unique ID
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.s3.review_data_bucket_arn  # ✅ No direct dependency on S3 output
  depends_on    = [module.s3]  # ✅ Ensures S3 exists before this permission
}

module "api_gateway" {
  source               = "./modules/api_gateway"
  lambda_invoke_arn    = module.lambda.lambda_invoke_arn
  lambda_function_name = module.lambda.lambda_function_name # ✅ Fixed Reference
}

module "eventbridge" {
  source             = "./modules/eventbridge"
  s3_bucket_name     = module.s3.review_data_bucket_id
  lambda_function_arn = module.lambda.lambda_function_arn  # ✅ Use the correct Lambda ARN
  #lambda_invoke_arn   = module.lambda.lambda_invoke_arn

}




output "api_gateway_url" {
  value = module.api_gateway.api_gateway_url
}


resource "aws_s3_bucket" "review_data" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_notification" "s3_event_trigger" {
  bucket = aws_s3_bucket.review_data.id

  lambda_function {
    lambda_function_arn = var.lambda_function_arn  # ✅ Use variable instead
    events              = ["s3:ObjectCreated:*"]
  }
}

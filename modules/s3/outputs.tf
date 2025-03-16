output "review_data_bucket_id" {
  description = "The ID of the S3 bucket for storing reviews"
  value       = aws_s3_bucket.review_data.id
}

output "review_data_bucket_arn" {
  description = "The ARN of the S3 bucket for storing reviews"
  value       = aws_s3_bucket.review_data.arn
  depends_on  = [aws_s3_bucket.review_data]  # ✅ Ensures this output exists AFTER S3 is created
}

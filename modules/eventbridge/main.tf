resource "aws_cloudwatch_event_rule" "s3_upload_rule" {
  name        = "s3-upload-event-rule"
  description = "Triggered when a new CSV file is uploaded to S3"

  event_pattern = <<EOF
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created"],
  "detail": {
    "bucket": {
      "name": ["${var.s3_bucket_name}"]
    },
    "object": {
      "key": [{"suffix": ".csv"}]
    }
  }
}
EOF
}


resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.s3_upload_rule.name
  target_id = "InvokeLambda"
  arn       = var.lambda_function_arn  # ✅ Use the correct Lambda ARN
}



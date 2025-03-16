# variables.tf
variable "aws_region" {
  default = "us-east-1"
}

variable "s3_bucket_name" {
  default = "ai-reviews-data"
}

variable "dynamodb_table_name" {
  default = "UserReviews"
}

variable "rds_db_name" {
  default = "reviewsdb"
}


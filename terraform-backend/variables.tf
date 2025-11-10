##########################################
# VARIABLES for terraform-backend
##########################################

variable "region" {
  description = "AWS region to create S3 bucket and DynamoDB table"
  type        = string
  default     = "eu-west-1"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for Terraform state file"
  type        = string
  default     = "dynamodb-terraform-locks-chinmayee"  # S3 Bucket
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "DynamoDB-terraform-locks-chinmayee"  # DynamoDB table
}
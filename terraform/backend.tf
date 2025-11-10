########################################## 
# Terraform Remote Backend Configuration
##########################################

terraform {
  backend "s3" {
    bucket         = "dynamodb-terraform-locks-chinmayee"      #  my S3 bucket
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "DynamoDB-terraform-locks-chinmayee"      # my DynamoDB table
  }
}
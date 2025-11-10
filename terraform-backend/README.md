# Terraform backend (S3 + DynamoDB)

This small Terraform project creates the S3 bucket and DynamoDB table used as the remote backend for the main infra.

Run:

  terraform init
  terraform apply -auto-approve

Then use the outputs to configure your main project's backend.
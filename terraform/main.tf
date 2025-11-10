##########################################
# AWS Provider
##########################################
provider "aws" {
  region = "eu-west-1"                     # Specifies the AWS region to deploy resources in
}

##########################################
# Terraform Configuration
##########################################
terraform {
  required_version = ">= 1.8.0"                    # Specifies the minimum required Terraform version
}

##########################################
# Local Values
##########################################
locals {
  vpc_cidr        = "10.20.0.0/16"             # CIDR block for the VPC
  public_a_cidr   = "10.20.1.0/24"         # CIDR block for the public subnet
  private_a_cidr  = "10.20.2.0/24"     # CIDR block for the private application subnet
  private_db_cidr = "10.20.3.0/24"    # CIDR block for the private database subnet

  tags = {
    Project   = "IRONHACK-PROJECT-1-Chinmayee"      # Tags to be applied to all resources for identification
    Env       = "dev"
    Owner     = "Chinmayee"                    
    ManagedBy = "Terraform"                     # Indicates that resources are managed by Terraform
  }
}

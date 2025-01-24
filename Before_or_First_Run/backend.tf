provider "aws" {
  region = "us-west-2" # Replace with your AWS region
}

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "terraformstatefiles-us-west-2" # Replace with a unique bucket name
  force_destroy = true

  tags = {
    Name        = "TerraformStateBucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "terraform_state_acl" {
  bucket = aws_s3_bucket.terraform_state[count.index].bucket
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state[count.index].bucket

  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST" # No need to provision capacity
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "TerraformLockTable"
    Environment = "Dev"
  }
}

# Output the S3 bucket name and DynamoDB table name
output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state[count.index].id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks[count.index].name
}

# Backend Configuration Block (requires manual addition)
terraform {
  backend "s3" {
    bucket         = "terraformstatefiles-us-west-2"     # Replace with your S3 bucket name
    key            = "terraform/state/terraform.tfstate" # State file path within the bucket
    region         = "us-west-2"                         # AWS region
    dynamodb_table = "terraform-locks"                   # DynamoDB table name
    encrypt        = true                                # Encrypt state file
  }
}

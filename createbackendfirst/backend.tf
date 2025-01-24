provider "aws" {
  region = "us-west-2" # Replace with your AWS region
}


resource "aws_s3_bucket" "terraform_state" {
  bucket        = "terraformstatefiles-us-west-2" # Replace with a unique bucket name
  force_destroy = true

  tags = {
    Name        = "TerraformStateBucket"
    Environment = "Dev"
  }
}

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

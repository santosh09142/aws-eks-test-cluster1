# DynamoDB Table for State Locking
data "aws_dynamodb_table" "existing_table" {
  name = "terraform-locks"
}

resource "aws_dynamodb_table" "terraform_locks" {
  count        = data.aws_dynamodb_table.existing_table.id == "" ? 1 : 0
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


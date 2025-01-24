# S3 Bucket for Terraform State
data "aws_s3_bucket" "existing_bucket" {
  bucket = "terraformstatefiles-us-west-2"
}

resource "aws_s3_bucket" "terraform_state" {
  count         = data.aws_s3_bucket.existing_bucket.id == "" ? 1 : 0
  bucket        = "terraformstatefiles-us-west-2" # Replace with a unique bucket name
  force_destroy = true

  tags = {
    Name        = "TerraformStateBucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "terraform_state_acl" {
  count  = length(aws_s3_bucket.terraform_state) > 0 ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].bucket
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  count  = length(aws_s3_bucket.terraform_state) > 0 ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].bucket

  versioning_configuration {
    status = "Enabled"
  }
}

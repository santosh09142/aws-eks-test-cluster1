# Output the S3 bucket name and DynamoDB table name
output "s3_bucket_name" {
  value = length(aws_s3_bucket.terraform_state) > 0 ? aws_s3_bucket.terraform_state[0].id : ""
}

output "dynamodb_table_name" {
  value = length(aws_dynamodb_table.terraform_locks) > 0 ? aws_dynamodb_table.terraform_locks[0].name : ""
}


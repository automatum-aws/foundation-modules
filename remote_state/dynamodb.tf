# DynamoDB Terraform state resources
resource "aws_dynamodb_table" "tfstate" {
  name         = "${var.customer_prefix}-tfstate-${data.aws_region.current.name}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  point_in_time_recovery {
    enabled = true
  }
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.tfstate.arn
  }
}

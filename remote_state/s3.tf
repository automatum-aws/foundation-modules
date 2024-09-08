# Terraform state S3 bucket
#tfsec:ignore:aws-s3-enable-bucket-logging:exp:2022-01-01
resource "aws_s3_bucket" "tfstate" {
  bucket = "${var.customer_prefix}-tfstate-${data.aws_region.current.name}"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.tfstate.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  versioning {
    enabled = true
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# SSL only for s3 bucket policy
resource "aws_s3_bucket_policy" "tfstate" {
  depends_on = [aws_s3_bucket_public_access_block.tfstate]
  bucket     = aws_s3_bucket.tfstate.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "TerraformState"
    Statement = [
      {
        Sid       = "AllowSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.tfstate.arn,
          "${aws_s3_bucket.tfstate.arn}/*"
        ]
        Condition = {
          IpAddress = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
}

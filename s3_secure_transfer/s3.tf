resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  logging {
    target_bucket = aws_s3_bucket.logging_sensitive_data_transfers.id
    target_prefix = "${aws_s3_bucket.this.id}/"
  }

  lifecycle_rule {
    id      = "ExpireSecrets"
    enabled = true
    expiration {
      days = 3
    }
  }
}

resource "aws_s3_bucket_notification" "sensitive_data_transfers_notification" {
  bucket = aws_s3_bucket[0].id
  depends_on = [
    aws_s3_bucket.sensitive_data_transfers,
  ]

  topic {
    topic_arn = var.sns_topic_arn
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_s3_bucket_public_access_block" "sensitive_data_transfers_access_policy" {
  bucket = aws_s3_bucket.sensitive_data_transfers.id

  depends_on = [
    aws_s3_bucket.sensitive_data_transfers,
    aws_s3_bucket_notification.sensitive_data_transfers_notification
  ]

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_ownership_controls" "sensitive_data_transfers_owner" {
  bucket = aws_s3_bucket.sensitive_data_transfers.id

  depends_on = [
    aws_s3_bucket.sensitive_data_transfers,
    aws_s3_bucket_public_access_block.sensitive_data_transfers_access_policy,
    aws_s3_bucket_notification.sensitive_data_transfers_notification
  ]

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# SSL only for s3 bucket policy
resource "aws_s3_bucket_policy" "tfstate" {
  bucket = aws_s3_bucket.this.id
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

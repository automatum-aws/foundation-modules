resource "aws_s3_bucket" "config_delivery_bucket" {
  count  = var.audit_account_id == "self" ? 1 : 0
  bucket = "${var.customer_prefix}-aws-config-delivery-bucket"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSConfigBucketPermissionsCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "config.amazonaws.com"
        ]
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${var.customer_prefix}-aws-config-delivery-bucket"
    },
    {
      "Sid": "AWSConfigBucketExistenceCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "config.amazonaws.com"
        ]
      },
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${var.customer_prefix}-aws-config-delivery-bucket"
    },
    {
      "Sid": "AWSConfigBucketDelivery",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "config.amazonaws.com"    
        ]
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.customer_prefix}-aws-config-delivery-bucket/AWSLogs/*",
      "Condition": { 
        "StringEquals": { 
          "s3:x-amz-acl": "bucket-owner-full-control" 
        }
      }
    },
    {
      "Sid": "ForceSSLOnlyAccess",
      "Effect": "Deny",
      "Principal": { "AWS": "*" },
      "Action": "s3:*",
      "Condition": {
        "Bool": { "aws:SecureTransport": false }
      },
      "Resource":"arn:aws:s3:::${var.customer_prefix}-aws-config-delivery-bucket/*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "config_s3_delivery" {
  count  = var.audit_account_id == "self" ? 1 : 0
  name   = "${var.customer_prefix}-aws-config-s3-delivery"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.config_delivery_bucket[0].arn}",
        "${aws_s3_bucket.config_delivery_bucket[0].arn}/*"
      ]
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "s3_config_policy_attach" {
  count      = var.audit_account_id == "self" ? 1 : 0
  role       = var.central_audit_account_role_name
  policy_arn = aws_iam_policy.config_s3_delivery[0].arn
}

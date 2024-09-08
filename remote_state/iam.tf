locals {
  organisation_account_identifiers = sort([for account_id in var.organisation_account_ids : "arn:aws:iam::${account_id}:root"])
}

data "aws_iam_policy_document" "tfstate_cross_account_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = local.organisation_account_identifiers
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_role" "cross_account_tfstate_role" {
  count              = var.is_primary_region ? 1 : 0
  name               = "terraform-cross-account-remote-state"
  assume_role_policy = data.aws_iam_policy_document.tfstate_cross_account_policy.json
}

resource "aws_iam_role_policy" "tfstate_policy" {
  name = "${data.aws_region.current.name}-tfstate-policy"
  role = var.is_primary_region ? aws_iam_role.cross_account_tfstate_role[0].id : var.cross_account_remote_state_role_id

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "s3:ListAllMyBuckets"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::*"
    },
    {
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.tfstate.arn}"
    },
    {
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.tfstate.arn}",
        "${aws_s3_bucket.tfstate.arn}/*"
      ]
    },
    {
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:DeleteItem"
      ],
      "Effect": "Allow",
      "Resource": "${aws_dynamodb_table.tfstate.arn}"
    },
    {
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_kms_key.tfstate.arn}"
      ]
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

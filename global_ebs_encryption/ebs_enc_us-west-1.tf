# Enable Default EBS encryption in region us-west-1
provider "aws" {
  region = "us-west-1"
  alias  = "us-west-1"
}

resource "aws_ebs_encryption_by_default" "ebs_encryption_us_west_1" {
  provider = aws.us-west-1
  enabled  = true
}

resource "aws_ebs_default_kms_key" "us_west_1_ebs_default_cmk" {
  provider = aws.us-west-1
  count    = var.use_cmk ? 1 : 0
  key_arn  = "arn:aws:kms:us-west-1:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.us_west_1_ebs_cmk[0].key_id}"
}

resource "aws_kms_key" "us_west_1_ebs_cmk" {
  count    = var.use_cmk ? 1 : 0
  provider = aws.us-west-1

  description             = "For EBS default encryption"
  deletion_window_in_days = 30
  multi_region            = true
  enable_key_rotation     = true
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "Key-CloudTrail-Org-Policy",
    "Statement": [
      {
        "Sid": "Enable IAM policies",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          },
        "Action": "kms:*",
        "Resource": "*"
      }
      ${var.cmk_enable_autoscaling_access ? "," : ""}
      ${var.cmk_enable_autoscaling_access ? <<EOF
      {
        "Sid": "Allow service-linked role use of the customer managed key",
        "Effect": "Allow",
        "Principal": {
            "AWS": [
                "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
            ]
        },
        "Action": [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
        ],
        "Resource": "*"
      }
      EOF
: ""}
      ${var.cmk_enable_autoscaling_access && var.cmk_policy_additional_statements != "" ? "," : ""}
      ${var.cmk_policy_additional_statements}
    ]
}
POLICY
}

resource "aws_kms_alias" "us_west_1_ebs_cmk_alias" {
  count    = var.use_cmk ? 1 : 0
  provider = aws.us-west-1

  name          = "alias/ebs-default-cmk-us-west-1"
  target_key_id = aws_kms_key.us_west_1_ebs_cmk[0].key_id
}


#!/bin/bash
# Usage:
# $ for i in $(aws ec2 describe-regions --output text | awk '{print $4}'); do rm -rf ebs_enc_$i.tf && ./src/template_gen.sh $i > gd_config_$i.tf; done

underscored=$(echo "$1" |  sed -r 's/-+/_/g')

cat <<EOF
# Enable AWS Org Wide Guard Duty in region $1
provider "aws" {
  region = "$1"
  alias  = "$1_audit"
  assume_role {
    role_arn     = local.audit_account_org_admin_role
    session_name = "TerraformFoundationGDSetup"
  }
}

provider "aws" {
  region = "$1"
  alias  = "$1_management"
}

resource "aws_guardduty_detector" "${underscored}_enable_main_account" {
  provider = aws.$1_management
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "${underscored}_audit_account_admin_delegate" {
  provider         = aws.$1_management
  admin_account_id = var.audit_account_id
}

resource "aws_guardduty_detector" "${underscored}_audit_detector" {
  provider = aws.$1_audit

  enable = true
  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "${underscored}_org_wide_guardduty_config" {
  provider = aws.$1_audit

  auto_enable = true
  detector_id = aws_guardduty_detector.${underscored}_audit_detector.id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

EOF

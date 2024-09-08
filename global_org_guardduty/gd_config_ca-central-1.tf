# Enable AWS Org Wide Guard Duty in region ca-central-1
provider "aws" {
  region = "ca-central-1"
  alias  = "ca-central-1_audit"
  assume_role {
    role_arn     = local.audit_account_org_admin_role
    session_name = "TerraformFoundationGDSetup"
  }
}

provider "aws" {
  region = "ca-central-1"
  alias  = "ca-central-1_management"
}

resource "aws_guardduty_detector" "ca_central_1_enable_main_account" {
  provider = aws.ca-central-1_management
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "ca_central_1_audit_account_admin_delegate" {
  provider         = aws.ca-central-1_management
  admin_account_id = var.audit_account_id
}

resource "aws_guardduty_detector" "ca_central_1_audit_detector" {
  provider = aws.ca-central-1_audit

  enable = true
  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "ca_central_1_org_wide_guardduty_config" {
  provider = aws.ca-central-1_audit

  auto_enable = true
  detector_id = aws_guardduty_detector.ca_central_1_audit_detector.id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}


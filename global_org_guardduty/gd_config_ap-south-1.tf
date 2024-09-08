# Enable AWS Org Wide Guard Duty in region ap-south-1
provider "aws" {
  region = "ap-south-1"
  alias  = "ap-south-1_audit"
  assume_role {
    role_arn     = local.audit_account_org_admin_role
    session_name = "TerraformFoundationGDSetup"
  }
}

provider "aws" {
  region = "ap-south-1"
  alias  = "ap-south-1_management"
}

resource "aws_guardduty_detector" "ap_south_1_enable_main_account" {
  provider = aws.ap-south-1_management
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "ap_south_1_audit_account_admin_delegate" {
  provider         = aws.ap-south-1_management
  admin_account_id = var.audit_account_id
}

resource "aws_guardduty_detector" "ap_south_1_audit_detector" {
  provider = aws.ap-south-1_audit

  enable = true
  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_organization_configuration" "ap_south_1_org_wide_guardduty_config" {
  provider = aws.ap-south-1_audit

  auto_enable = true
  detector_id = aws_guardduty_detector.ap_south_1_audit_detector.id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}


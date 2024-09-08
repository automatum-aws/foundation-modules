terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.65.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.7.2"
    }
  }
  required_version = ">= 1.0.11"
}

provider "aws" {
  alias  = "member"
  region = var.aws_region
  assume_role {
    role_arn     = local.account_org_admin_role
    session_name = "TerraformFoundation"
  }

  default_tags {
    tags = {
      Environment = "CrossAccount"
      Owner       = "MainAccount"
      Project     = "AWSAudit"
      ManagedBy   = "Terraform"
    }
  }
}

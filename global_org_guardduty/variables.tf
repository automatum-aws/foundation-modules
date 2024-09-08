variable "audit_account_id" {
  type        = string
  description = "AWS Account ID for Audit account."
}

variable "role_name" {
  type        = string
  description = "Name of IAM role to be created that is trusted from Main account. Defaults to AWSOrgAdmin"
  default     = "AWSOrgAdmin"
}

locals {
  audit_account_org_admin_role = "arn:aws:iam::${var.audit_account_id}:role/${var.role_name}"
}

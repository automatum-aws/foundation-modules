locals {
  account_org_admin_role = "arn:aws:iam::${aws_organizations_account.account.id}:role/${var.role_name}"
}

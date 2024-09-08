resource "aws_organizations_account" "account" {
  name                       = var.account_name
  email                      = var.account_email
  parent_id                  = var.parent_id
  role_name                  = var.role_name
  iam_user_access_to_billing = var.iam_user_access_to_billing ? "ALLOW" : "DENY"
  tags                       = var.additonal_tags
}

# This is needed to wait for AWS Fraud checks to run and initialize the account.
resource "time_sleep" "account_init_sleep" {
  depends_on = [
    aws_organizations_account.account
  ]

  create_duration = "5m"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account#attributes-reference
output "account_id" {
  value       = aws_organizations_account.account.id
  description = "The AWS Account Id of the created account."
}

output "account_arn" {
  value       = aws_organizations_account.account.arn
  description = "The AWS Account ARN of the created account."
}

output "account_org_admin_role" {
  value       = local.account_org_admin_role
  description = "The AWS Account Org Admin IAM Role of the created account. This role trusts the main account and has administrator privileges."
}

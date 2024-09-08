# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organization#attributes-reference
output "aws_org_id" {
  value       = aws_organizations_organization.org.id
  description = "AWS Organization Id"
}

output "standard_ous" {
  value       = var.standard_ous
  description = "AWS Organization Standard Organizational Units"
}

output "org_root_id" {
  value       = aws_organizations_organization.org.roots[0].id
  description = "AWS Organization Root Id"
}

output "security_ou_id" {
  value       = aws_organizations_organizational_unit.standard_ous["Security"].id
  description = "AWS Organization Organizational Unit Id for the Security OU"
}

output "infrastructure_ou_id" {
  value       = aws_organizations_organizational_unit.standard_ous["Infrastructure"].id
  description = "AWS Organization Organizational Unit Id for the Infrastructure OU"
}

output "workload_ou_id" {
  value       = aws_organizations_organizational_unit.standard_ous["Workloads"].id
  description = "AWS Organization Organizational Unit Id for the Workloads OU"
}

output "security_accounts" {
  value       = aws_organizations_organizational_unit.standard_ous["Security"].accounts.*.id
  description = "AWS Organization Organizational Unit Id for the Security OU"
}

output "infrastructure_accounts" {
  value       = aws_organizations_organizational_unit.standard_ous["Infrastructure"].accounts.*.id
  description = "AWS Account Ids in the Security OU"
}

output "workload_accounts" {
  value       = aws_organizations_organizational_unit.standard_ous["Workloads"].accounts.*.id
  description = "AWS Account Ids in the Workloads OU"
}

output "all_account_ids" {
  value       = sort([for account in aws_organizations_organization.org.accounts : account.id])
  description = "All AWS Account Ids in the AWS Organization"
}

output "accounts_map" {
  value = merge({
    for k in aws_organizations_organization.org.accounts[*] :
    k.name => k.id
  })
  description = "List of all accounts and a mapping from account name to AWS Account Id"
}


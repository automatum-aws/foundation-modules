output "cross_account_remote_state_role_id" {
  value       = var.is_primary_region ? aws_iam_role.cross_account_tfstate_role[0].id : ""
  description = "In primary region this has the AWS IAM Role Id. If secondary region then empty string."
}

output "cross_account_remote_state_role_arn" {
  value       = var.is_primary_region ? aws_iam_role.cross_account_tfstate_role[0].arn : ""
  description = "In primary region this has the AWS IAM Role ARN. If secondary region then empty string."
}

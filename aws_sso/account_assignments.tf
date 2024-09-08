resource "aws_ssoadmin_account_assignment" "this" {
  for_each = { for assignment in local.account_assignments : "${assignment.principal_name}.${assignment.permission_set.name}.${assignment.account_id}" => assignment }

  instance_arn       = each.value.permission_set.instance_arn
  permission_set_arn = each.value.permission_set.arn
  principal_id       = data.aws_identitystore_group.this[each.value.sso_group_name].id
  principal_type     = "GROUP"

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"
}

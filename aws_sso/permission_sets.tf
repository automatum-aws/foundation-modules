resource "aws_ssoadmin_permission_set" "this" {
  for_each = var.permission_sets

  name             = each.key
  description      = lookup(each.value, "description", null)
  instance_arn     = local.ssoadmin_instance_arn
  relay_state      = lookup(each.value, "relay_state", null)
  session_duration = lookup(each.value, "session_duration", null)
  tags             = lookup(each.value, "tags", {})
}

resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each = { for ps_name, ps_attrs in var.permission_sets : ps_name => ps_attrs if ps_attrs.inline_policy != "" }

  inline_policy      = each.value.inline_policy
  instance_arn       = local.ssoadmin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = { for ps in local.ps_policy_maps : "${ps.ps_name}.${ps.policy_arn}" => ps }

  instance_arn       = local.ssoadmin_instance_arn
  managed_policy_arn = each.value.policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.ps_name].arn
}

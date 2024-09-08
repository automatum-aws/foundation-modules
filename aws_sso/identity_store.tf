data "aws_identitystore_group" "this" {
  for_each          = toset(local.sso_groups)
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  filter {
    attribute_path  = "DisplayName"
    attribute_value = each.value
  }
}

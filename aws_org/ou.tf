resource "aws_organizations_organizational_unit" "standard_ous" {
  for_each  = toset(var.standard_ous)
  name      = each.key
  parent_id = aws_organizations_organization.org.roots[0].id
}

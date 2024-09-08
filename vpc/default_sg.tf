# Ensures no rules in default sg https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group
# https://www.trendmicro.com/cloudoneconformity/knowledge-base/aws/EC2/security-group-egress-any.html#E1Xhluwg
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
}

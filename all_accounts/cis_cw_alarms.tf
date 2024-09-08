resource "aws_cloudwatch_log_group" "cis" {
  name = "cis-logs"
}

module "cis_cw" {
  source         = "git@github.com:automatum-aws/foundation-modules.git//cloudwatch_cis_alarms?ref=latest"
  log_group_name = aws_cloudwatch_log_group.cis.name
}

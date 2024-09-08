resource "aws_flow_log" "flow_log_all" {
  count                = var.flow_log_bucket_arn != "" ? 1 : 0
  log_destination      = var.flow_log_bucket_arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc.id
}

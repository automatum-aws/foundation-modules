resource "aws_config_aggregate_authorization" "config_auth" {
  account_id = var.audit_account_id == "self" ? data.aws_caller_identity.current.account_id : var.audit_account_id
  region     = var.aws_region
}

resource "aws_config_delivery_channel" "central_bucket" {
  name           = "audit_account_config_bucket"
  s3_bucket_name = "${var.customer_prefix}-aws-config-delivery-bucket"
  depends_on     = [aws_config_configuration_recorder.account_recorder]
}

resource "aws_config_configuration_recorder" "account_recorder" {
  name     = "central_audit_account_recorder"
  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig"
  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_configuration_recorder_status" "enable_account_recording" {
  name       = aws_config_configuration_recorder.account_recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.central_bucket]
}

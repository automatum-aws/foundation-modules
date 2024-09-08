## AWS Config resources for region: ca-central-1 - generated by /src/template_gen.sh
provider "aws" {
  region = "ca-central-1"
  alias  = "ca-central-1"
}

resource "aws_config_aggregate_authorization" "ca_central_1_config_auth" {
  provider   = aws.ca-central-1
  account_id = var.audit_account_id == "self" ? data.aws_caller_identity.current.account_id : var.audit_account_id
  region     = "ca-central-1"
}

resource "aws_config_delivery_channel" "ca_central_1_to_central_audit_bucket" {
  provider       = aws.ca-central-1
  name           = "audit_account_config_bucket"
  s3_bucket_name = "${var.customer_prefix}-aws-config-delivery-bucket"
  depends_on     = [aws_config_configuration_recorder.ca_central_1_account_recorder]
}

resource "aws_config_configuration_recorder" "ca_central_1_account_recorder" {
  provider = aws.ca-central-1
  name     = "central_audit_account_recorder"
  role_arn = aws_iam_service_linked_role.config.arn
  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_configuration_recorder_status" "ca_central_1_enable_account_recording" {
  provider   = aws.ca-central-1
  name       = aws_config_configuration_recorder.ca_central_1_account_recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.ca_central_1_to_central_audit_bucket]
}

## AWS Config resources for region: eu-west-3 - generated by /src/template_gen.sh
provider "aws" {
  region = "eu-west-3"
  alias  = "eu-west-3"
}

resource "aws_config_aggregate_authorization" "eu_west_3_config_auth" {
  provider   = aws.eu-west-3
  account_id = var.audit_account_id == "self" ? data.aws_caller_identity.current.account_id : var.audit_account_id
  region     = "eu-west-3"
}

resource "aws_config_delivery_channel" "eu_west_3_to_central_audit_bucket" {
  provider       = aws.eu-west-3
  name           = "audit_account_config_bucket"
  s3_bucket_name = "${var.customer_prefix}-aws-config-delivery-bucket"
  depends_on     = [aws_config_configuration_recorder.eu_west_3_account_recorder]
}

resource "aws_config_configuration_recorder" "eu_west_3_account_recorder" {
  provider = aws.eu-west-3
  name     = "central_audit_account_recorder"
  role_arn = aws_iam_service_linked_role.config.arn
  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_configuration_recorder_status" "eu_west_3_enable_account_recording" {
  provider   = aws.eu-west-3
  name       = aws_config_configuration_recorder.eu_west_3_account_recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.eu_west_3_to_central_audit_bucket]
}


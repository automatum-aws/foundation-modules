module "multi_region_ebs_encryption" {
  source = "git@github.com:automatum-aws/foundation-modules.git//global_ebs_encryption?ref=latest"

  use_cmk                          = var.ebs_default_enc_use_cmk
  cmk_enable_autoscaling_access    = var.ebs_default_enc_cmk_autoscaling_policy
  cmk_policy_additional_statements = var.ebs_default_enc_cmk_custom_statements
}

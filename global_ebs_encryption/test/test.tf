module "multi_region_ebs_enc" {
  source = "../."

  use_cmk = true
  #cmk_enable_autoscaling_access = true # Needs Autoscaling Service Linked role in account
}

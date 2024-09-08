provider "aws" {
  alias  = "ap-south-1"
  region = "ap-south-1"
}

module "remote_state_ap_south_1" {
  count = contains(var.regions_to_enable, "ap-south-1") ? 1 : 0
  providers = {
    aws = aws.ap-south-1
  }
  source                             = "git@github.com:automatum-aws/foundation-modules.git//remote_state?ref=latest"
  customer_prefix                    = var.customer_prefix
  cross_account_remote_state_role_id = var.cross_account_remote_state_role_id
}

provider "aws" {
  alias  = "ap-southeast-1"
  region = "ap-southeast-1"
}

module "remote_state_ap_southeast_1" {
  count = contains(var.regions_to_enable, "ap-southeast-1") ? 1 : 0
  providers = {
    aws = aws.ap-southeast-1
  }
  source                             = "git@github.com:automatum-aws/foundation-modules.git//remote_state?ref=latest"
  customer_prefix                    = var.customer_prefix
  cross_account_remote_state_role_id = var.cross_account_remote_state_role_id
}

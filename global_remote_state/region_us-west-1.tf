provider "aws" {
  alias  = "us-west-1"
  region = "us-west-1"
}

module "remote_state_us_west_1" {
  count = contains(var.regions_to_enable, "us-west-1") ? 1 : 0
  providers = {
    aws = aws.us-west-1
  }
  source                             = "git@github.com:automatum-aws/foundation-modules.git//remote_state?ref=latest"
  customer_prefix                    = var.customer_prefix
  cross_account_remote_state_role_id = var.cross_account_remote_state_role_id
}

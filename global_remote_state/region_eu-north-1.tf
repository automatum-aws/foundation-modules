provider "aws" {
  alias  = "eu-north-1"
  region = "eu-north-1"
}

module "remote_state_eu_north_1" {
  count = contains(var.regions_to_enable, "eu-north-1") ? 1 : 0
  providers = {
    aws = aws.eu-north-1
  }
  source                             = "git@github.com:automatum-aws/foundation-modules.git//remote_state?ref=latest"
  customer_prefix                    = var.customer_prefix
  cross_account_remote_state_role_id = var.cross_account_remote_state_role_id
}

provider "aws" {
  alias  = "eu-west-2"
  region = "eu-west-2"
}

module "remote_state_eu_west_2" {
  count = contains(var.regions_to_enable, "eu-west-2") ? 1 : 0
  providers = {
    aws = aws.eu-west-2
  }
  source                             = "git@github.com:automatum-aws/foundation-modules.git//remote_state?ref=latest"
  customer_prefix                    = var.customer_prefix
  cross_account_remote_state_role_id = var.cross_account_remote_state_role_id
}

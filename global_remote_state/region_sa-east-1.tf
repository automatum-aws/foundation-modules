provider "aws" {
  alias  = "sa-east-1"
  region = "sa-east-1"
}

module "remote_state_sa_east_1" {
  count = contains(var.regions_to_enable, "sa-east-1") ? 1 : 0
  providers = {
    aws = aws.sa-east-1
  }
  source                             = "git@github.com:automatum-aws/foundation-modules.git//remote_state?ref=latest"
  customer_prefix                    = var.customer_prefix
  cross_account_remote_state_role_id = var.cross_account_remote_state_role_id
}

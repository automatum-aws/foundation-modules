module "automatum_access" {
  providers = {
    aws = aws.member
  }
  source           = "git@github.com:automatum-aws/foundation-modules.git//automatum_access?ref=latest"
  read_access      = var.enable_automatum_read_access
  write_access     = var.enable_automatum_write_access
  managed_services = var.enable_automatum_managed_services_access

  depends_on = [
    time_sleep.account_init_sleep
  ]
}

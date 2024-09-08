module "vpc_test" {
  source         = "git@github.com:automatum-aws/foundation-modules.git//"
  naming_prefix  = "automatum-tftest"
  network_prefix = "10.0"
}

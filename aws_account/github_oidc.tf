module "github_access" {
  providers = {
    aws = aws.member
  }
  count           = var.grant_github_access ? 1 : 0
  source          = "git@github.com:automatum-aws/foundation-modules.git//github_oidc_aws_access?ref=latest"
  repository_path = var.github_repository_path

  depends_on = [
    time_sleep.account_init_sleep
  ]
}

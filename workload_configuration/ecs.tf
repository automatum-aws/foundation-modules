module "ecs" {
  source                             = "git@github.com:automatum-aws/foundation-modules.git//ecs_cluster?ref=latest"
  name                               = var.ecs_config.name
  capacity_providers                 = var.ecs_config.capacity_providers
  default_capacity_provider_strategy = var.ecs_config.default_capacity_provider_strategy
}

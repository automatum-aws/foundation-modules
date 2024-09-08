variable "ecs_config" {
  type = object({
    name                               = string
    capacity_providers                 = list(string)
    default_capacity_provider_strategy = list(map(string))
  })
  default = {
    name               = "ecs_cluster"
    capacity_providers = ["FARGATE", "FARGATE_SPOT"]
    default_capacity_provider_strategy = [
      {
        capacity_provider = "FARGATE"
      }
    ]
  }
  description = "AWS ECS Cluster configuration. Default is Fargate to allow for each launching of serverless containers."
}

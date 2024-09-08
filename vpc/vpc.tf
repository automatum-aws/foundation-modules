resource "aws_vpc" "vpc" {
  cidr_block       = local.vpc_cidr
  instance_tenancy = var.instance_tenancy

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge({
    Name = "${local.environment}-vpc"
    },
    var.tags
  )
}

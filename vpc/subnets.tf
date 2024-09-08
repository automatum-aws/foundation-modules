
resource "aws_subnet" "public_subnets" {
  count = local.number_of_azs

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = local.azs[count.index]

  # Conditionally add public subnet tags for EKS
  tags = var.enable_eks_tags == "true" && var.eks_public_nodes == "true" ? (
    merge({
      "kubernetes.io/role/elb" = "1",
      Name = "${local.environment}-public-sn-${trimprefix(local.azs[count.index], data.aws_region.current.name)}" },
      var.tags
    )
    ) : (
    merge({
      Name = "${local.environment}-public-sn-${trimprefix(local.azs[count.index],
      data.aws_region.current.name)}" },
      var.tags
    )
  )

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_subnet" "private_subnets" {
  count = local.number_of_azs

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.subnet_cidrs[count.index + 4]
  availability_zone = local.azs[count.index]
  # Conditionally add private subnet tags for EKS
  tags = var.enable_eks_tags == "true" ? (
    merge({
      "kubernetes.io/role/internal-elb" = "1",
      Name = "${local.environment}-private-sn-${trimprefix(local.azs[count.index], data.aws_region.current.name)}" },
      var.tags
    )
    ) : (
    merge({
      Name = "${local.environment}-private-sn-${trimprefix(local.azs[count.index],
      data.aws_region.current.name)}" },
      var.tags
    )
  )

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_subnet" "secure_subnets" {
  count = local.number_of_azs

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.subnet_cidrs[count.index + 8]
  availability_zone = local.azs[count.index]
  tags = merge({
    Name = "${local.environment}-secure-sn-${trimprefix(local.azs[count.index], data.aws_region.current.name)}"
    },
    var.tags
  )
}

resource "aws_subnet" "transit_subnets" {
  count = var.create_tgw || var.share_tgw ? local.number_of_azs : 0

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.subnet_cidrs[count.index + 12]
  map_public_ip_on_launch = true
  availability_zone       = local.azs[count.index]
  tags = merge({
    Name = "${local.environment}-tgw-sn-${trimprefix(local.azs[count.index], data.aws_region.current.name)}"
    },
    var.tags
  )
}

#####
# Gateways
#####
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${local.environment}-igw"
    },
    var.tags
  )
}

# NAT Gateways
resource "aws_eip" "nat_gw_eips" {
  count = var.number_of_ngws
  vpc   = true
  tags = merge({
    Name = "${local.environment}-nat-gw-${trimprefix(local.azs[count.index], data.aws_region.current.name)}"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "nat_gws" {
  count         = var.number_of_ngws
  allocation_id = aws_eip.nat_gw_eips[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
  tags = merge({
    Name = "${local.environment}-nat-gw-${trimprefix(local.azs[count.index], data.aws_region.current.name)}"
    },
    var.tags
  )
}

######
## Public Routing
######
# NB: Publicly addressed instances may not work with firewall and NAT gateways enabled due to edge association route needed for  NetFw and NATgws
resource "aws_route_table" "public_route_tables" {
  count = local.number_of_azs

  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${local.environment}-public-rt-${trimprefix(local.azs[count.index], data.aws_region.current.name)}"
    },
    var.tags
  )
}

resource "aws_route_table_association" "rt_assocations_public" {
  count          = local.number_of_azs
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_tables[count.index].id
}

resource "aws_route" "public_to_igw" {
  count                  = local.number_of_azs
  route_table_id         = aws_route_table.public_route_tables[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

######
## Private Routing
######
resource "aws_route_table" "private_route_tables" {
  # If we have no NAT Gateways, don't create private route tables
  count = var.number_of_ngws == 0 ? 0 : local.number_of_azs

  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${local.environment}-private-rt-${trimprefix(local.azs[count.index], data.aws_region.current.name)}"
    },
    var.tags
  )
}

resource "aws_route_table_association" "rt_assocations_private" {
  count     = local.number_of_azs
  subnet_id = aws_subnet.private_subnets[count.index].id
  # If we have no NAT Gateways, associate the secure subnet routing table to the private subnets
  route_table_id = var.number_of_ngws == 0 ? aws_route_table.secure_route_tables[count.index].id : aws_route_table.private_route_tables[count.index].id
}

# Conditionally creates route to transit gateway if created
resource "aws_route" "private_to_tgw" {
  count                  = var.create_tgw || var.share_tgw ? local.number_of_azs : 0
  route_table_id         = aws_route_table.private_route_tables[count.index].id
  destination_cidr_block = var.tgw_super_prefix
  transit_gateway_id     = !var.create_tgw && var.share_tgw ? var.tgw_id : aws_ec2_transit_gateway.transit_gateway[0].id
}

resource "aws_route" "private_to_ngw" {
  count                  = local.number_of_azs
  route_table_id         = aws_route_table.private_route_tables[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  # If we have more AZs than NAT Gateways, use the first NAT Gateway for the rest
  nat_gateway_id = count.index >= var.number_of_ngws ? aws_nat_gateway.nat_gws[0].id : aws_nat_gateway.nat_gws[count.index].id
}

######
## Secure Routing
######
resource "aws_route_table" "secure_route_tables" {
  count = local.number_of_azs

  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${local.environment}-secure-rt-${trimprefix(local.azs[count.index], data.aws_region.current.name)}"
    },
    var.tags
  )
}

resource "aws_route_table_association" "rt_assocations_secure" {
  count          = local.number_of_azs
  subnet_id      = aws_subnet.secure_subnets[count.index].id
  route_table_id = aws_route_table.secure_route_tables[count.index].id
}

# Conditionally creates route to transit gateway if created
# resource "aws_route" "secure_to_tgw" {
#   count                  = !var.create_tgw || !var.share_tgw ? 0 : local.number_of_azs
#   route_table_id         = aws_route_table.secure_route_tables[count.index].id
#   destination_cidr_block = local.tgw_super_net
#   transit_gateway_id     = coalesce(aws_ec2_transit_gateway.transit_gateway[0].id, var.tgw_id)
# }

resource "aws_route" "secure_to_ngw" {
  count                  = local.number_of_azs
  route_table_id         = aws_route_table.secure_route_tables[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  # If we have more AZs than NAT Gateways, use the first NAT Gateway for the rest
  nat_gateway_id = count.index >= var.number_of_ngws ? aws_nat_gateway.nat_gws[0].id : aws_nat_gateway.nat_gws[count.index].id
}

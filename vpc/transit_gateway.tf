resource "aws_ec2_transit_gateway" "transit_gateway" {
  count       = var.create_tgw ? 1 : 0
  description = "${local.environment} Transit Gateway"

  tags = merge({
    Name = "${local.environment}-tgw"
    },
    var.tags
  )
}

resource "aws_ec2_transit_gateway_vpc_attachment" "shared_attachment" {
  count              = var.create_tgw ? 1 : 0
  subnet_ids         = aws_subnet.transit_subnets.*.id
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway[0].id
  vpc_id             = aws_vpc.vpc.id

  tags = merge({
    Name = "${local.environment}-tgw-shared-attach"
    },
    var.tags
  )
}

resource "aws_ec2_transit_gateway_vpc_attachment" "wl_attachment" {
  count              = !var.create_tgw && !var.isolated_tgw_rt_tbl && var.share_tgw ? 1 : 0
  subnet_ids         = aws_subnet.transit_subnets.*.id
  transit_gateway_id = var.tgw_id
  vpc_id             = aws_vpc.vpc.id
  tags = merge({
    Name = "${local.environment}-tgw-wl-attach"
    },
    var.tags
  )

  depends_on = [
    aws_ram_resource_share_accepter.receiver_accept,
  ]
}

# For isolated workloads. Shared routes are leaked into isolated route table.
resource "aws_ec2_transit_gateway_route_table" "tgw_rt_tbl_isolated" {
  count              = var.create_tgw && var.isolated_tgw_rt_tbl ? 1 : 0
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway[0].id
  tags = merge({
    Name = "${local.environment}-tgw-rt-tbl-isolated"
    },
    var.tags
  )
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_rt_prop_shared_iso" {
  count                          = var.create_tgw && var.share_tgw && var.isolated_tgw_rt_tbl ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_attachment[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt_tbl_isolated[0].id
}

# for Direct Connect, need another table prop to leak the routes in if that's the customer requirement
# resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_rt_prop_dc_iso" {
#   count              = var.create_tgw ? 1 : 0
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dc_attachment.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt_tbl_isolated[0].id
# }

resource "aws_ec2_transit_gateway_vpc_attachment" "isolated_attachment" {
  count              = !var.create_tgw && var.share_tgw && var.isolated_tgw_rt_tbl ? 1 : 0
  subnet_ids         = aws_subnet.transit_subnets.*.id
  transit_gateway_id = var.tgw_id
  vpc_id             = aws_vpc.vpc.id

  tags = merge({
    Name = "${local.environment}-tgw-iso-attach"
    },
    var.tags
  )

  depends_on = [
    aws_ram_resource_share_accepter.receiver_accept
  ]
}

resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "tgw_attach_accept_iso" {
  count = var.create_tgw && var.share_tgw && length(var.isolated_attach_id) > 0 ? 1 : 0

  transit_gateway_attachment_id                   = var.isolated_attach_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge({
    Name = "${local.environment}-tgw-iso-attach"
    },
    var.tags
  )
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_rt_assoc_iso_attach" {
  count                          = var.create_tgw && var.share_tgw && length(var.isolated_attach_id) > 0 ? 1 : 0
  transit_gateway_attachment_id  = var.isolated_attach_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt_tbl_isolated[0].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_rt_prop_wl_iso" {
  count                          = var.create_tgw && var.share_tgw && length(var.isolated_attach_id) > 0 ? 1 : 0
  transit_gateway_attachment_id  = var.isolated_attach_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt_tbl_isolated[0].id
}

# Propagate dev route in default table for share reachability. This is to allow shared traffic return path
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_rt_prop_wl_iso_default" {
  count                          = var.create_tgw && var.share_tgw && length(var.isolated_attach_id) > 0 ? 1 : 0
  transit_gateway_attachment_id  = var.isolated_attach_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.transit_gateway[0].propagation_default_route_table_id
}



# manual tasks to accept the attachment and move to isolated route table.

# Needs aws_ec2_transit_gateway_vpc_attachments data resource to be able to approve pending attachments.
# https://github.com/hashicorp/terraform-provider-aws/pull/12409


##########################
# Resource Access Manager
##########################
resource "aws_ram_resource_share" "this" {
  count = var.create_tgw && var.share_tgw ? 1 : 0
  name  = "${local.environment}-resource-share"

  allow_external_principals = true

  tags = merge({
    Name = "${local.environment}-resource-share"
    },
    var.tags
  )

}

resource "aws_ram_resource_association" "ram_tgw_assoc" {
  count              = var.create_tgw && var.share_tgw ? 1 : 0
  resource_arn       = aws_ec2_transit_gateway.transit_gateway[0].arn
  resource_share_arn = aws_ram_resource_share.this[0].arn
}

resource "aws_ram_principal_association" "invite" {
  count = var.create_tgw && var.share_tgw ? length(var.ram_invite_principals) : 0

  principal          = var.ram_invite_principals[count.index]
  resource_share_arn = aws_ram_resource_share.this[0].arn
}

resource "aws_ram_resource_share_accepter" "receiver_accept" {
  count     = !var.create_tgw && var.share_tgw ? 1 : 0
  share_arn = var.ram_resource_share_arn
}

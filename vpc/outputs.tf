## VPC Outputs
output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "VPC Id"
}

output "vpc_cidr" {
  value       = aws_vpc.vpc.cidr_block
  description = "CIDR Block"
}

## Subnet Outputs
output "subnet_ids" {
  value = concat(
    aws_subnet.public_subnets.*.id,
    aws_subnet.private_subnets.*.id,
    aws_subnet.secure_subnets.*.id
  )
  description = "All subnet ids created in the VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public_subnets.*.id
  description = "Public subnet ids created in the VPC"
}

output "public_subnet_cidrs" {
  value       = aws_subnet.public_subnets.*.cidr_block
  description = "Public subnet CIDR blocks created in the VPC"
}

output "private_subnet_ids" {
  value       = aws_subnet.private_subnets.*.id
  description = "Private subnet ids created in the VPC"
}

output "private_subnet_cidrs" {
  value       = aws_subnet.private_subnets.*.cidr_block
  description = "Private subnet CIDR blocks created in the VPC"
}

output "secure_subnet_ids" {
  value       = aws_subnet.secure_subnets.*.id
  description = "Secure subnet ids created in the VPC"
}

output "secure_subnet_cidrs" {
  value       = aws_subnet.secure_subnets.*.cidr_block
  description = "Secure subnet CIDR blocks created in the VPC"
}

## Route Table outputs
output "public_rt_ids" {
  value       = aws_route_table.public_route_tables.*.id
  description = "Public route table ids"
}

output "private_rt_ids" {
  value       = aws_route_table.private_route_tables.*.id
  description = "Private route table ids"
}

output "secure_rt_ids" {
  value       = aws_route_table.secure_route_tables.*.id
  description = "Secure route table ids"
}

## TGW Outputs
output "tgw_id" {
  description = "If variable `create_tgw` is true then Transit Gateway Id else empty string."
  value       = var.create_tgw ? element(concat(aws_ec2_transit_gateway.transit_gateway.*.id, [""]), 0) : ""
}

output "tgw_owner" {
  description = "If variable `create_tgw` is true then Transit Gateway Owner Id else empty string."
  value       = var.create_tgw ? aws_ec2_transit_gateway.transit_gateway[0].owner_id : ""
}

# aws_ram_resource_share
output "ram_resource_share_id" {
  description = "If variable `create_tgw` and `share_tgw` is true then The Amazon Resource Name (ARN) of the resource share else empty string"
  value       = var.create_tgw && var.share_tgw ? element(concat(aws_ram_resource_share.this.*.id, [""]), 0) : ""
}

# aws_ram_principal_association
output "ram_principal_association_id" {
  description = "If variable `create_tgw` and `share_tgw` is true then The Amazon Resource Name (ARN) of the Resource Share and the principal, separated by a comma else empty string"
  value       = var.create_tgw && var.share_tgw ? element(concat(aws_ram_principal_association.invite.*.id, [""]), 0) : ""
}

output "tgw_shared_attachment_id" {
  description = "If variable `create_tgw` is true then output the shared attachment id else empty string"
  value       = var.create_tgw ? element(concat(aws_ec2_transit_gateway_vpc_attachment.shared_attachment.*.id, [""]), 0) : ""
}

output "tgw_wl_attachment_id" {
  description = "If variable `create_tgw` is true then output the workload attachment id else empty string"
  value       = !var.create_tgw && var.share_tgw ? element(concat(aws_ec2_transit_gateway_vpc_attachment.wl_attachment.*.id, [""]), 0) : ""
}

output "tgw_iso_attachment_id" {
  description = "If variable `create_tgw` is true then output the isolated attachment id else empty string"
  value       = !var.create_tgw && var.share_tgw && var.isolated_tgw_rt_tbl ? element(concat(aws_ec2_transit_gateway_vpc_attachment.isolated_attachment.*.id, [""]), 0) : ""
}

# output "ram_resource_share_accepted_id" {
#   description = "If variable `create_tgw` is false and `share_tgw` is true then output RAM accepted_id resource else empty string."
#   value       = !var.create_tgw && var.share_tgw ? element(concat(aws_ram_resource_share_accepter.receiver_accept, [""]), 0) : ""
# }

#####
# Gateway VPC Endpoints
#####
# At this time only S3 and Dynamo are supported
resource "aws_vpc_endpoint" "s3" {
  count        = var.create_s3_gateway ? 1 : 0
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = concat(
    aws_route_table.public_route_tables.*.id,
    aws_route_table.private_route_tables.*.id,
    aws_route_table.secure_route_tables.*.id
  )
  tags = merge({
    Name = "${local.environment}-s3-vpce"
    },
    var.tags
  )
}

resource "aws_vpc_endpoint" "dynamodb" {
  count        = var.create_dynamo_gateway ? 1 : 0
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  route_table_ids = concat(
    aws_route_table.public_route_tables.*.id,
    aws_route_table.private_route_tables.*.id,
    aws_route_table.secure_route_tables.*.id
  )
  tags = merge({
    Name = "${local.environment}-dynamo-vpce"
    },
    var.tags
  )
}

#####
# Interface VPC Endpoints
#####

resource "aws_vpc_endpoint" "endpoint" {
  for_each            = toset(var.vpc_interface_endpoints)
  vpc_id              = aws_vpc.vpc.id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private_subnets.*.id
  security_group_ids  = [aws_security_group.aws_svc_endpoint_sg[0].id]
  tags = merge({
    Name = "${local.environment}-${replace(each.key, ".", "-")}-vpce"
    },
    var.tags
  )
}
resource "aws_security_group" "aws_svc_endpoint_sg" {
  count       = length(var.vpc_interface_endpoints) > 0 ? 1 : 0
  name        = "${local.environment}-aws-svc-vpc-endpoint"
  description = "For AWS service VPC endpoints"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allows traffic from VPC to service"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    "Name" = "${local.environment}-aws-svc-vpc-endpoint"
    },
    var.tags
  )

}

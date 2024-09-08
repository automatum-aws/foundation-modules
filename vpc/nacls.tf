## Public NACL
resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.vpc.id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    icmp_code  = 0
    icmp_type  = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    icmp_code  = 0
    icmp_type  = 0
  }

  subnet_ids = aws_subnet.public_subnets.*.id

  tags = merge({
    Name = "${local.environment}-public-nacl"
    },
    var.tags
  )
}

## Private NACL
resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.vpc.id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    icmp_code  = 0
    icmp_type  = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    icmp_code  = 0
    icmp_type  = 0
  }

  subnet_ids = aws_subnet.private_subnets.*.id

  tags = merge({
    Name = "${local.environment}-private-nacl"
    },
    var.tags
  )
}

## Secure NACL
resource "aws_network_acl" "secure" {
  vpc_id = aws_vpc.vpc.id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "deny"
    cidr_block = cidrsubnet("${var.network_prefix}.0.0/${var.vpc_cidr_block}", 2, 0)
    from_port  = 0
    to_port    = 0
    icmp_code  = 0
    icmp_type  = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    icmp_code  = 0
    icmp_type  = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "deny"
    cidr_block = cidrsubnet("${var.network_prefix}.0.0/${var.vpc_cidr_block}", 2, 0)
    from_port  = 0
    to_port    = 0
    icmp_code  = 0
    icmp_type  = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    icmp_code  = 0
    icmp_type  = 0
  }

  subnet_ids = aws_subnet.secure_subnets.*.id

  tags = merge({
    Name = "${local.environment}-secure-nacl"
    },
    var.tags
  )
}

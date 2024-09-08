data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "event_lambda" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "lambda.amazonaws.com"
      ]
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "deldefvpc" {
  statement {
    sid = "deleteec2resource"
    actions = [
      "ec2:DescribeInternetGateways",
      "ec2:DeleteSubnet",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeRegions",
      "ec2:DescribeAccountAttributes",
      "ec2:DeleteVpc",
      "ec2:DetachInternetGateway",
      "ec2:DescribeSubnets",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups"
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }

  statement {
    sid = "deletedefaultvpc"
    actions = [
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteInternetGateway",
      "ec2:DeleteNetworkAcl",
      "ec2:DeleteRouteTable"
    ]
    resources = [
      "arn:aws:ec2:*:*:route-table/*",
      "arn:aws:ec2:*:*:security-group/*",
      "arn:aws:ec2:*:*:network-acl/*",
      "arn:aws:ec2:*:*:internet-gateway/*"
    ]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "cross_account" {
  statement {
    sid = "AssumeCrossAccountRoles"
    actions = [
      "sts:*",
    ]
    resources = [
      "arn:aws:iam::*:role/${var.org_admin_role_name}",
    ]
    effect = "Allow"
  }
}

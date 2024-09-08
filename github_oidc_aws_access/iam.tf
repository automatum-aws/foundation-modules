resource "aws_iam_openid_connect_provider" "this" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:${var.repository_path}:*"
      ]
    }
  }
}

resource "aws_iam_role" "github_read_only" {
  name                 = "Foundation-ReadOnly"
  max_session_duration = 3600
  path                 = "/"
  managed_policy_arns  = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  assume_role_policy   = data.aws_iam_policy_document.this.json
  inline_policy {
    name = "assume_remote_state"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["sts:AssumeRole"]
          Effect   = "Allow"
          Resource = "arn:aws:iam::*:role/terraform-cross-account-remote-state"
        },
        {
          Action   = ["cur:DescribeReportDefinitions"]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action   = ["account:GetAlternateContact"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

resource "aws_iam_role" "github_write" {
  name                 = "Foundation-Write"
  max_session_duration = 3600
  path                 = "/"
  managed_policy_arns  = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  assume_role_policy   = data.aws_iam_policy_document.this.json
}

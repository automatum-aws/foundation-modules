data "aws_iam_policy_document" "automatum_identity_account" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["394966198205"]
    }

    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = [true]
    }
  }
}

resource "aws_iam_role" "automatum_admin" {
  count                = var.write_access ? 1 : 0
  name                 = "Admin"
  max_session_duration = 43200
  path                 = "/"
  managed_policy_arns  = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  assume_role_policy   = data.aws_iam_policy_document.automatum_identity_account.json
}

resource "aws_iam_role" "automatum_readonly" {
  count                = var.read_access ? 1 : 0
  name                 = "ReadOnly"
  max_session_duration = 43200
  path                 = "/"
  managed_policy_arns  = ["arn:aws:iam::aws:policy/job-function/ViewOnlyAccess", "arn:aws:iam::aws:policy/ReadOnlyAccess"]
  assume_role_policy   = data.aws_iam_policy_document.automatum_identity_account.json
  inline_policy {
    name = "eks"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "eks:DescribeNodegroup"
            , "eks:ListNodegroups"
            , "eks:DescribeCluster"
            , "eks:ListClusters"
            , "eks:AccessKubernetesApi"
            , "ssm:GetParameter"
            , "eks:ListUpdates"
            , "eks:ListFargateProfiles"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

resource "aws_iam_role" "automatum_billing" {
  count                = var.read_access ? 1 : 0
  name                 = "Billing"
  max_session_duration = 43200
  path                 = "/"
  managed_policy_arns  = ["arn:aws:iam::aws:policy/job-function/Billing"]
  assume_role_policy   = data.aws_iam_policy_document.automatum_identity_account.json
}


data "aws_iam_policy_document" "automatum_control_plane_account" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["947503054808"]
    }
  }
}

resource "aws_iam_role" "automatum_managed_services_read_only" {
  count                = var.managed_services ? 1 : 0
  name                 = "ManagedServicesReadOnly"
  max_session_duration = 43200
  path                 = "/"
  managed_policy_arns  = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  assume_role_policy   = data.aws_iam_policy_document.automatum_control_plane_account.json
}

resource "aws_iam_role" "automatum_patching" {
  count                = var.managed_services ? 1 : 0
  name                 = "Patching"
  max_session_duration = 43200
  path                 = "/"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  , "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"]
  assume_role_policy = data.aws_iam_policy_document.automatum_control_plane_account.json

  inline_policy {
    name = "eks"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ec2:Describe*"
            , "ec2:CreateSnapshot"
            , "ec2:CreateImage"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

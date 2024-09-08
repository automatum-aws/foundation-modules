resource "aws_sns_topic" "this" {
  name              = var.sns_topic_name
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "this" {
  for_each  = toset(var.email_addresses)
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = each.value
}


resource "aws_sns_topic_policy" "this" {
  arn    = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "sns:Subscribe",
      "sns:SetTopicAttributes",
      "sns:RemovePermission",
      "sns:Receive",
      "sns:Publish",
      "sns:ListSubscriptionsByTopic",
      "sns:GetTopicAttributes",
      "sns:DeleteTopic",
      "sns:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        "${data.aws_caller_identity.current.account_id}",
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.this.arn,
    ]

    sid = "__default_statement_ID"
  }

  statement {
    actions = [
      "sns:Publish",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.this.arn,
    ]

    sid = "TrustCWEToPublishEventsToMyTopic"
  }
}

resource "aws_kms_key" "topic_key" {
  description             = "CMK for SNS topic ${var.sns_topic_name}"
  deletion_window_in_days = 7
  policy                  = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "SNS-KeyPolicy",
  "Statement": [
    {
      "Sid": "Allow access for Root User",
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow access for Key User (SNS Service Principal)",
      "Effect": "Allow",
      "Principal": {"Service": "sns.amazonaws.com"},
      "Action": [
        "kms:GenerateDataKey*",
        "kms:Decrypt"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_kms_alias" "topic_key_alias" {
  name          = "alias/sns-${var.sns_topic_name}"
  target_key_id = aws_kms_key.topic_key.key_id
}

resource "aws_inspector_resource_group" "default_assessment_resource_group" {
  count = var.enable_inspector ? 1 : 0
  tags = {
    AwsInspector = "true"
  }
}

resource "aws_inspector_assessment_target" "default_assessment_target" {
  count              = var.enable_inspector ? 1 : 0
  name               = "default-assessment-target"
  resource_group_arn = aws_inspector_resource_group.default_assessment_resource_group[0].arn
}

resource "aws_inspector_assessment_template" "default_assessment_template" {
  count      = var.enable_inspector ? 1 : 0
  name       = "default-assessment-template"
  target_arn = aws_inspector_assessment_target.default_assessment_target[0].arn
  duration   = 3600

  rules_package_arns = [
    "arn:aws:inspector:ap-southeast-2:454640832652:rulespackage/0-D5TGAxiR", # CVE
    "arn:aws:inspector:ap-southeast-2:454640832652:rulespackage/0-Vkd2Vxjq", # CIS Operating System Security Configuration Benchmarks
    "arn:aws:inspector:ap-southeast-2:454640832652:rulespackage/0-asL6HRgN", # Security Best Practice
  ]
}

data "aws_iam_policy_document" "inspector_event_role_policy" {
  count = var.enable_inspector ? 1 : 0
  statement {
    sid = "StartAssessment"
    actions = [
      "inspector:StartAssessmentRun",
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "inspector_event_role" {
  count = var.enable_inspector ? 1 : 0
  name  = "inspector-event-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "inspector_event" {
  count  = var.enable_inspector ? 1 : 0
  name   = "inspector-event-policy"
  role   = aws_iam_role.inspector_event_role[0].id
  policy = data.aws_iam_policy_document.inspector_event_role_policy[0].json
}

resource "aws_cloudwatch_event_rule" "inspector_event_schedule" {
  count               = var.enable_inspector ? 1 : 0
  name                = "default-inspector-schedule"
  description         = "Trigger an Inspector Assessment"
  schedule_expression = "cron(0 16 ? * SUN *)"
}

resource "aws_cloudwatch_event_target" "inspector_event_target" {
  count    = var.enable_inspector ? 1 : 0
  rule     = aws_cloudwatch_event_rule.inspector_event_schedule[0].name
  arn      = aws_inspector_assessment_template.default_assessment_template[0].arn
  role_arn = aws_iam_role.inspector_event_role[0].arn
}

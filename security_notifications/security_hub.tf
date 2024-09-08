resource "aws_cloudwatch_event_rule" "security_hub_event_rule" {
  count         = var.enable_security_hub_notifications ? 1 : 0
  name          = "detect-securityhub-finding"
  description   = "A CloudWatch Event Rule that triggers on AWS Security Hub findings. The Event Rule can be used to trigger notifications or remediative actions using AWS Lambda."
  is_enabled    = true
  event_pattern = <<PATTERN
{
  "detail-type": [
    "Security Hub Findings - Imported"
  ],
  "source": [
    "aws.securityhub"
  ]
}
PATTERN

}

resource "aws_cloudwatch_event_target" "target_for_security_hub_event_rule" {
  count     = var.enable_security_hub_notifications ? 1 : 0
  rule      = aws_cloudwatch_event_rule.security_hub_event_rule[0].name
  target_id = "security_hub_event_rule"
  arn       = var.sns_topic_arn

  input_transformer {
    input_paths = {
      findingTime : "$.detail.findings[0].updatedAt",
      finding : "$.detail.findings[0].Types[0]",
      region : "$.detail.findings[0].Resources[0].Region",
      account : "$.detail.findings[0].AwsAccountId",
      findingDescription : "$.detail.findings[0].Description"
    }
    input_template = <<EOF
    "AWS SecurityHub finding in <region> for Account: <account>. The finding is <finding> and the description of the finding is <findingDescription>."
    EOF
  }
}

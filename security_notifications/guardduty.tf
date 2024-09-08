resource "aws_cloudwatch_event_rule" "guardduty_notifications_high_sev" {
  count       = var.enable_guardduty_high_severity_notifications ? 1 : 0
  name        = "GuardDutyAlertHighSeverity"
  description = "CloudWatch Rule to send email if GuardDuty has a finding"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.guardduty"
  ],
  "detail-type": [
    "GuardDuty Finding"
  ],
  "detail": {
    "severity" : [
      7,7.0,7.1,7.2,7.3,7.4,7.5,7.6,7.7,7.8,7.9,8,8.0,8.1,8.2,8.3,8.4,8.5,8.6,8.7,8.8,8.9
    ]
  } 
}  
PATTERN
}

resource "aws_cloudwatch_event_target" "guardduty_notifications_high_sev" {
  target_id = "guardduty-notifications-high-sev"
  rule      = aws_cloudwatch_event_rule.guardduty_notifications_high_sev[0].name
  arn       = var.sns_topic_arn

  input_transformer {
    input_paths = {
      account : "$.account",
      eventFirstSeen : "$.detail.service.eventFirstSeen",
      eventLastSeen : "$.detail.service.eventLastSeen",
      count : "$.detail.service.count",
      Finding_Type : "$.detail.type",
      region : "$.region",
      Finding_description : "$.detail.description"
    }
    input_template = <<EOF

"Guard Duty Alert - High Severity. Customer Prefix: ${var.customer_prefix}, Account Id: <account>"
"You have a GuardDuty Finding Type: <Finding_Type> in the Region: <region>" 
"Description: <Finding_description>."
"The first attempt was on <eventFirstSeen> and the most recent attempt on <eventLastSeen>."
"The total occurrence is <count>."

EOF
  }
}

resource "aws_cloudwatch_event_rule" "guardduty_notifications_medium_sev" {
  count       = var.enable_guardduty_medium_severity_notifications ? 1 : 0
  name        = "GuardDutyAlertMediumeverity"
  description = "CloudWatch Rule to send email if GuardDuty has a finding"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.guardduty"
  ],
  "detail-type": [
    "GuardDuty Finding"
  ],
  "detail": {
    "severity" : [
      4,4.0,4.1,4.2,4.3,4.4,4.5,4.6,4.7,4.8,4.9,5,5.0,5.1,5.2,5.3,5.4,5.5,5.6,5.7,5.8,5.9,6,6.0,6.1,6.2,6.3,6.4,6.5,6.6,6.7,6.8,6.9
    ]
  } 
}  
PATTERN
}

resource "aws_cloudwatch_event_target" "guardduty_notifications_medium_sev" {
  count     = var.enable_guardduty_medium_severity_notifications ? 1 : 0
  target_id = "guardduty-notifications-medium-sev"
  rule      = aws_cloudwatch_event_rule.guardduty_notifications_medium_sev[0].name
  arn       = var.sns_topic_arn

  input_transformer {
    input_paths = {
      account : "$.account",
      eventFirstSeen : "$.detail.service.eventFirstSeen",
      eventLastSeen : "$.detail.service.eventLastSeen",
      count : "$.detail.service.count",
      Finding_Type : "$.detail.type",
      region : "$.region",
      Finding_description : "$.detail.description"
    }
    input_template = <<EOF

"Guard Duty Alert - High Severity. Customer Prefix: ${var.customer_prefix}, Account Id: <account>"
"You have a GuardDuty Finding Type: <Finding_Type> in the Region: <region>" 
"Description: <Finding_description>."
"The first attempt was on <eventFirstSeen> and the most recent attempt on <eventLastSeen>."
"The total occurrence is <count>."

EOF
  }
}

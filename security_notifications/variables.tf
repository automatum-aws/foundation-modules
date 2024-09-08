variable "sns_topic_arn" {
  type        = string
  description = "SNS Topic to send all notifications to."
}

variable "enable_guardduty_high_severity_notifications" {
  type        = bool
  description = "Enable high severity notifications from GuardDuty to be sent to the SNS topic."
  default     = true
}

variable "enable_guardduty_medium_severity_notifications" {
  type        = bool
  description = "Enable medium severity notifications from GuardDuty to be sent to the SNS topic."
  default     = true
}

variable "customer_prefix" {
  type        = string
  description = "Prefix for all resources with the customer name. Should be lower case characters starting with an alpha character and be consistent across the environment. Only `-` as a special character."
}

variable "enable_security_hub_notifications" {
  type        = bool
  description = "Enable notifications from Security Hub to be sent to the SNS topic."
  default     = true
}

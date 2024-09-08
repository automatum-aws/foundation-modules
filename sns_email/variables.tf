variable "sns_topic_name" {
  type        = string
  description = "SNS Topic name to create"
}

variable "email_addresses" {
  type        = list(string)
  description = "List of email addresses to email when a message is sent to SNS."
}

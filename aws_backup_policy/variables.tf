variable "region" {
  type        = string
  description = "AWS Region to enable "
}

variable "aws_backup_role_name" {
  type        = string
  description = "AWS IAM Role Name that is provisioned into each account to run backups."
  default     = "aws-backup"
}

variable "backup_cron_schedule" {
  description = "Cron schedules specified in UTC timezone. https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html"
  type = object({
    daily   = string
    weekly  = string
    monthly = string
    yearly  = string
  })

  default = {
    daily   = "cron(0 15 ? * * *)"
    weekly  = "cron(0 18 ? * 1 *)"
    monthly = "cron(0 21 ? * 1#1 *)"
    yearly  = "cron(0 12 1 1 ? *)"
  }
}

variable "organisational_units" {
  type        = list(string)
  description = "AWS Organizational Units to apply AWS Backup policies to."
}

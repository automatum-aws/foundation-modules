variable "bucket_name" {
  type        = string
  description = "Bucket name to create"
}

variable "sns_topic_arn" {
  type        = string
  description = "SNS Topic to notify when files are uploaded"
}

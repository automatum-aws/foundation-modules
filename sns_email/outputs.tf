output "sns_topic_id" {
  value       = aws_sns_topic.this.id
  description = "SNS Topic Id"
}

output "sns_topic_arn" {
  value       = aws_sns_topic.this.arn
  description = "SNS Topic ARN"
}

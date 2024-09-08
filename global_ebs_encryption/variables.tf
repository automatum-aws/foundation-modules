variable "use_cmk" {
  type        = bool
  default     = false
  description = "Use CMK KMS key for default EBS encryption. One will be created per active region."
}

variable "cmk_policy_additional_statements" {
  type        = string
  default     = ""
  description = "Optional, additional KMS key statements to add to CMK for EBS default encryption. Note `use_cmk` must be `true` to take effect."
}

variable "cmk_enable_autoscaling_access" {
  type        = bool
  default     = false
  description = "Allow autoscaling service to use EBS with default CMK, defaults to `false`"
}

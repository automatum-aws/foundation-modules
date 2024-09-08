variable "enable_inspector" {
  default     = true
  description = "Whether AWS Inspector resources should be created, defaults to true"
  type        = bool
}

variable "ebs_default_enc_use_cmk" {
  default     = false
  description = "For default EBS encryption in the account. Use a CMK KMS key, defaults to false"
  type        = bool
}

variable "ebs_default_enc_cmk_autoscaling_policy" {
  default     = false
  description = "For default EBS encryption in the account. Grants access to the AWS Autoscaling service to use/create EBS volumes wiht the CMK. Autoscaling Service Linked role must be present in account, and ebs_default_enc_use_cmk must be true, defaults to false"
  type        = bool
}

variable "ebs_default_enc_cmk_custom_statements" {
  default     = ""
  description = "For default EBS encryption in the account. Additional JSON Statements to add to CMK for default EBS encryption. ebs_default_enc_use_cmk must be true, defaults to empty"
  type        = string
}

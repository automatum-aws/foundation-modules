variable "customer_prefix" {
  type        = string
  description = "Prefix for all resources with the customer name. Should be lower case characters starting with an alpha character and be consistent across the environment. Only `-` as a special character."
}

variable "is_primary_region" {
  type        = bool
  description = "If primary region then the IAM roles are created."
  default     = false
}

variable "cross_account_remote_state_role_id" {
  type        = string
  description = "Used in non-primary regions this value is required to attach an extra policy to allow access to the extra resources in the secondary regions."
  default     = ""
}

variable "organisation_account_ids" {
  type        = list(string)
  description = "AWS Account Ids to assume the cross account remote state role."
  default     = []
}

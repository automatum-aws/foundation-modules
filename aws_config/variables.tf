variable "audit_account_id" {
  type        = string
  description = "AWS Account ID of Centralized AWS Config Account"
}

variable "customer_prefix" {
  type        = string
  description = "Prefix for all resources with the customer name. Should be lower case characters starting with an alpha character and be consistent across the environment. Only `-` as a special character."
}

variable "central_audit_account_role_name" {
  type        = string
  description = "Needed if central Audit account - IAM Role name for Config to use."
  default     = ""
}

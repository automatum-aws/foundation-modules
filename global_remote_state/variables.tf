variable "cross_account_remote_state_role_id" {
  type        = string
  description = "Used in non-primary regions this value is required to attach an extra policy to allow access to the extra resources in the secondary regions."
  default     = ""
}

variable "regions_to_enable" {
  type        = list(string)
  description = "Secondary regions to enable for Terraform Remote State."
  default     = []
}

variable "customer_prefix" {
  type        = string
  description = "Prefix for all resources with the customer name. Should be lower case characters starting with an alpha character and be consistent across the environment. Only `-` as a special character."
}

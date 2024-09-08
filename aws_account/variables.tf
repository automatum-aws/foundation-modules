variable "account_name" {
  type        = string
  description = "Human friendly name of account"
}

variable "account_email" {
  type        = string
  description = "Email address for account"
}

variable "operations_contact" {
  type        = map(string)
  description = "Map with email address, phone number, name and title for account operations contact"
  default = {
    "email"        = ""
    "phone_number" = ""
    "name"         = ""
    "title"        = ""
  }
}

variable "billing_contact" {
  type        = map(string)
  description = "Map with email address, phone number, name and title for account billing contact"
  default = {
    "email"        = ""
    "phone_number" = ""
    "name"         = ""
    "title"        = ""
  }
}

variable "security_contact" {
  type        = map(string)
  description = "Map with email address, phone number, name and title for account security contact"
  default = {
    "email"        = ""
    "phone_number" = ""
    "name"         = ""
    "title"        = ""
  }
}

variable "aws_region" {
  type        = string
  description = "AWS Region to set up account for"
}

variable "parent_id" {
  type        = string
  description = "Parent AWS Org/OU for account to go under."
}

variable "role_name" {
  type        = string
  description = "Name of IAM role to be created that is trusted from Main account. Defaults to AWSOrgAdmin"
  default     = "AWSOrgAdmin"
}

variable "iam_user_access_to_billing" {
  type        = bool
  description = "Whether IAM users have access to billing. Defaults to true"
  default     = true
}


variable "additonal_tags" {
  type        = map(any)
  description = "Additional tags to add to account."
  default     = {}
}

variable "grant_github_access" {
  type        = bool
  description = "Grant GitHub OIDC access to Foundation-ReadOnly and Foundation-Write roles"
  default     = false
}

variable "github_repository_path" {
  type        = string
  description = "Needed if grant_github_access is true - GitHub Repository path to allow access to deploy into accounts. eg. org/repo"
  default     = ""
}

variable "enable_automatum_read_access" {
  type        = bool
  description = "Enable Automatum Read Only Access"
  default     = false
}

variable "enable_automatum_write_access" {
  type        = bool
  description = "Enable Automatum Admin Access"
  default     = false
}

variable "enable_automatum_managed_services_access" {
  type        = bool
  description = "Enable Automatum Managed Services Access"
  default     = false
}

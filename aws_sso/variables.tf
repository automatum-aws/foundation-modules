variable "permission_sets" {
  description = "AWS SSO Permission Sets to create."
  type = map(object({
    description      = string
    session_duration = string
    managed_policies = list(string)
    inline_policy    = string
  }))
  default = {
    AdministratorAccess = {
      description      = "Provides full access to AWS services and resources.",
      session_duration = "PT12H",
      managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      inline_policy    = ""
    }
  }
}

variable "account_assignments" {
  description = "TBA"
  type = list(object({
    sso_group_name      = string,
    permission_set_name = string,
    account_ids         = list(string)
  }))

  default = []
}

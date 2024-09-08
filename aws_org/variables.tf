variable "standard_ous" {
  type        = list(any)
  description = "List of standard OUs as per Well Architected Framework, defaults to https://docs.aws.amazon.com/whitepapers/latest/organizing-your-aws-environment/recommended-ous.html (Accessed Nov 2021)"
  default = [
    "Security",
    "Infrastructure",
    "Sandbox",
    "Workloads",
    "Policy Staging",
    "Suspended",
    "Individual Business Users",
    "Exceptions",
    "Deployments",
    "Transitional"
  ]
}

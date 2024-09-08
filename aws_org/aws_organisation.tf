resource "aws_organizations_organization" "org" {
  aws_service_access_principals = [
    "account.amazonaws.com",
    "aws-artifact-account-sync.amazonaws.com",
    "auditmanager.amazonaws.com",
    "backup.amazonaws.com",
    "member.org.stacksets.cloudformation.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "compute-optimizer.amazonaws.com",
    "config.amazonaws.com",
    "config-multiaccountsetup.amazonaws.com",
    "fms.amazonaws.com",
    "guardduty.amazonaws.com",
    "health.amazonaws.com",
    "license-manager.amazonaws.com",
    "license-manager.member-account.amazonaws.com",
    "macie.amazonaws.com",
    "license-management.marketplace.amazonaws.com",
    "ram.amazonaws.com",
    "securityhub.amazonaws.com",
    "storage-lens.s3.amazonaws.com",
    "servicecatalog.amazonaws.com",
    "servicequotas.amazonaws.com",
    "sso.amazonaws.com",
    "ssm.amazonaws.com",
    "tagpolicies.tag.amazonaws.com",
    "reporting.trustedadvisor.amazonaws.com"
  ]

  enabled_policy_types = ["SERVICE_CONTROL_POLICY", "TAG_POLICY", "BACKUP_POLICY", "AISERVICES_OPT_OUT_POLICY"]

  feature_set = "ALL"
}

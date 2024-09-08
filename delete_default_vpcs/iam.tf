resource "aws_iam_role" "delete_default_vpcs_role" {
  name                 = "delete-default-vpcs-role"
  max_session_duration = 43200
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AWSOrganizationsReadOnlyAccess"
  ]
  assume_role_policy = data.aws_iam_policy_document.event_lambda.json
  inline_policy {
    name   = "AssumeOrgAdminRole"
    policy = data.aws_iam_policy_document.cross_account.json
  }
  inline_policy {
    name   = "DeleteMainAccountDefVPC"
    policy = data.aws_iam_policy_document.deldefvpc.json
  }
}

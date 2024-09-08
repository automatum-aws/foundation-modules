resource "aws_iam_service_linked_role" "config" {
  aws_service_name = "config.amazonaws.com"
}

# Shouldn't be needed - created as part of AWS Org account creation
#resource "aws_iam_service_linked_role" "multi_acc_config" {
#  aws_service_name = "config-multiaccountsetup.amazonaws.com"
#}

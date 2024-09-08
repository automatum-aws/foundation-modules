resource "aws_kms_key" "tfstate" {
  description             = "Key for Terraform state."
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

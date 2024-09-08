resource "aws_backup_vault" "backup_vault" {
  name = "aws-backup-vault"
}

resource "aws_backup_region_settings" "this" {
  resource_type_opt_in_preference = {
    "DynamoDB"        = true
    "Aurora"          = true
    "EBS"             = true
    "EC2"             = true
    "EFS"             = true
    "FSx"             = true
    "RDS"             = true
    "Storage Gateway" = true
    "DocumentDB"      = true
    "Neptune"         = true
    "VirtualMachine"  = true
  }
}

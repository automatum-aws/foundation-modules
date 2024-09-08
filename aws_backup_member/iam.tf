data "aws_iam_policy_document" "aws_backup_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "aws_backup_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.aws_backup_role.name
}

resource "aws_iam_role" "aws_backup_role" {
  name               = "aws-backup"
  assume_role_policy = data.aws_iam_policy_document.aws_backup_role.json
}

resource "aws_instance" "bastion_instance" {
  ami           = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  root_block_device {
    volume_size = var.ebs_size
    volume_type = var.ebs_type
    encrypted   = true
  }

  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name

  subnet_id       = var.subnet
  security_groups = var.security_groups

  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

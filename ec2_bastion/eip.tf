resource "aws_eip" "bastion_eip" {
  count = var.publicly_accessible ? 1 : 0

  vpc = true
}

resource "aws_eip_association" "bastion_eip_association" {
  count = var.publicly_accessible ? 1 : 0

  instance_id   = aws_instance.bastion_instance.id
  allocation_id = aws_eip.bastion_eip[0].id
}

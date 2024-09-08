resource "aws_iam_role" "bastion_ssm_role" {
  name               = "${var.customer_prefix}-bastion-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${var.customer_prefix}-bastion-profile"
  role = aws_iam_role.bastion_ssm_role.id
}

resource "aws_iam_policy_attachment" "ssm_bastion_policy_attach_core" {
  name       = "bsation-ssm-core-attachment"
  roles      = [aws_iam_role.bastion_ssm_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "ssm_bastion_policy_attach_ec2roleforssm" {
  name       = "bsation-ssm-ec2roleforssm-attachment"
  roles      = [aws_iam_role.bastion_ssm_role.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

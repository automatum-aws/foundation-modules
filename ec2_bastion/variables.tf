variable "customer_prefix" {
  type        = string
  description = "String to prefix resources with."
}

variable "subnet" {
  type        = string
  description = "VPC Subnet to launch instance into."
}

variable "publicly_accessible" {
  type        = bool
  description = "Determines if instance is publicy accessible (assinges EIP), defaults to false."
  default     = false
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type to launch, defaults to t3.micro"
  default     = "t3.micro"
}

variable "ami_id" {
  type        = string
  description = "Custom AMI to launch instance with. Defaults to latest Amazon Linux 2."
  default     = ""
}

variable "ebs_type" {
  type        = string
  description = "EBS Volume type to use, defaults to gp3"
  default     = "gp3"
}

variable "ebs_size" {
  type        = number
  description = "Size in GiB of root EBS volume, defaults to 20."
  default     = 20
}

variable "security_groups" {
  type        = list(any)
  description = "List of security group IDs to attach to bastion."
  default     = []
}

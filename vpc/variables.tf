# Grabs what AZs are available in the region
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

locals {
  # custprefix-workload-region-whatever
  environment = "${var.naming_prefix}-${data.aws_region.current.name}"
  vpc_cidr    = "${var.network_prefix}.0.0/${var.vpc_cidr_block}"
  # This looks gnarly but simply splits the vpc up into 16 subnets - giving 4 bits to each and 12 to tgw subnets
  subnet_cidrs  = cidrsubnets(local.vpc_cidr, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 12, 12, 12, 12)
  azs           = data.aws_availability_zones.available.names
  number_of_azs = length(data.aws_availability_zones.available.names)
}

variable "naming_prefix" {
  description = "Customer's name for prefixing resources, should be identitiy-workload, e.g. automatum-shared"
  type        = string
}

variable "create_tgw" {
  description = "Create a Transit Gateway and subnets for it. Default is false"
  type        = bool
  default     = false
}
variable "share_tgw" {
  description = "Share the transit Gateway via RAM to the other workloads. Default is false"
  type        = bool
  default     = false
}

variable "isolated_tgw_rt_tbl" {
  description = "Provision transit Gateway isolated route table. Default is false"
  type        = bool
  default     = false
}

variable "isolated_attach_id" {
  description = "TGW attachment id of the isolated workload. Default is false"
  type        = string
  default     = ""
}


variable "tgw_id" {
  description = "The transit Gateway id for routing. Default is null"
  type        = string
  default     = null
}

variable "ram_invite_principals" {
  description = "A list of principals to share TGW with. Possible values are an AWS account ID, an AWS Organizations Organization ARN, or an AWS Organizations Organization Unit ARN"
  type        = list(string)
  default     = []
}

variable "ram_resource_share_arn" {
  description = "ARN of RAM resource share. Default is Null"
  type        = string
  default     = null
}

variable "vpc_cidr_block" {
  description = "VPC Network CIDR block"
  type        = string
  default     = "16"
}
variable "tgw_super_prefix" {
  description = "Organisation Super net prefix. Default is 10.0.0.0/8"
  type        = string
  default     = "10.0.0.0/8"
}

variable "network_prefix" {
  description = "First two octets for VPC IP range"
  type        = string
}

variable "create_s3_gateway" {
  description = "Create an S3 Gateway, defaults to true."
  type        = bool
  default     = true
}

variable "create_dynamo_gateway" {
  description = "Create a Dynamo Gateway, defaults to true."
  type        = bool
  default     = true
}

variable "instance_tenancy" {
  description = "Instance tenancy for VPC"
  type        = string
  default     = "default"
}

variable "tags" {
  description = "Additional tags to add to resources. Defaults to empty."
  type        = map(string)
  default     = {}
}

variable "number_of_ngws" {
  description = "Number of NAT Gateways to create, defaults to 0"
  type        = number
  default     = 0
}

variable "enable_eks_tags" {
  type        = string
  description = "Tag subnets with tags needed for EKS. Defaults to false."
  default     = "false"
}

variable "eks_public_nodes" {
  type        = string
  description = "Controls whether to tag public subnets for EKS usage. Defaults to false."
  default     = "false"
}

variable "flow_log_bucket_arn" {
  type        = string
  description = "S3 bucket ARN of where to send flow logs."
  default     = ""
}

variable "vpc_interface_endpoints" {
  type        = list(any)
  description = "AWS services to create endpoints for. Defaults to none"
  default     = []
}

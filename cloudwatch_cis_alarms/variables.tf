variable "disabled_controls" {
  description = "List of IDs of disabled CIS controls"
  type        = list(string)
  default     = []
}

variable "namespace" {
  description = "The namespace where metric filter and metric alarm should be cleated"
  type        = string
  default     = "CISBenchmark"
}

variable "log_group_name" {
  description = "The name of the log group to associate the metric filter with"
  type        = string
  default     = ""
}

variable "alarm_actions" {
  description = "List of ARNs to put as Cloudwatch Alarms actions (eg, ARN of SNS topic)"
  type        = list(string)
  default     = []
}

variable "actions_enabled" {
  description = "Indicates whether or not actions should be executed during any changes to the alarm's state."
  type        = bool
  default     = true
}

locals {
  all_controls = {
    UnauthorizedAPICalls = {
      pattern     = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
      description = "Monitoring unauthorized API calls will help reveal application errors and may reduce time to detect malicious activity."
    }

    NoMFAConsoleSignin = {
      pattern     = "{ ($.eventName = \"ConsoleLogin\") && ($.additionalEventData.MFAUsed != \"Yes\") }"
      description = "Monitoring for single-factor console logins will increase visibility into accounts that are not protected by MFA."
    }

    RootUsage = {
      pattern     = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
      description = "Monitoring for root account logins will provide visibility into the use of a fully privileged account and an opportunity to reduce the use of it."
    }

    IAMChanges = {
      pattern     = "{($.eventName=DeleteGroupPolicy)||($.eventName=DeleteRolePolicy)||($.eventName=DeleteUserPolicy)||($.eventName=PutGroupPolicy)||($.eventName=PutRolePolicy)||($.eventName=PutUserPolicy)||($.eventName=CreatePolicy)||($.eventName=DeletePolicy)||($.eventName=CreatePolicyVersion)||($.eventName=DeletePolicyVersion)||($.eventName=AttachRolePolicy)||($.eventName=DetachRolePolicy)||($.eventName=AttachUserPolicy)||($.eventName=DetachUserPolicy)||($.eventName=AttachGroupPolicy)||($.eventName=DetachGroupPolicy)}"
      description = "Monitoring changes to IAM policies will help ensure authentication and authorization controls remain intact."
    }

    CloudTrailCfgChanges = {
      pattern     = "{ ($.eventName = CreateTrail) || ($.eventName = UpdateTrail) || ($.eventName = DeleteTrail) || ($.eventName = StartLogging) || ($.eventName = StopLogging) }"
      description = "Monitoring changes to CloudTrail's configuration will help ensure sustained visibility to activities performed in the AWS account."
    }


    ConsoleSigninFailures = {
      pattern     = "{ ($.eventName = ConsoleLogin) && ($.errorMessage = \"Failed authentication\") }"
      description = "Monitoring failed console logins may decrease lead time to detect an attempt to brute force a credential, which may provide an indicator, such as source IP, that can be used in other event correlation."
    }


    DisableOrDeleteCMK = {
      pattern     = "{ ($.eventSource = kms.amazonaws.com) && (($.eventName = DisableKey) || ($.eventName = ScheduleKeyDeletion)) }"
      description = "Monitoring failed console logins may decrease lead time to detect an attempt to brute force a credential, which may provide an indicator, such as source IP, that can be used in other event correlation."
    }

    S3BucketPolicyChanges = {
      pattern     = "{ ($.eventSource = s3.amazonaws.com) && (($.eventName = PutBucketAcl) || ($.eventName = PutBucketPolicy) || ($.eventName = PutBucketCors) || ($.eventName = PutBucketLifecycle) || ($.eventName = PutBucketReplication) || ($.eventName = DeleteBucketPolicy) || ($.eventName = DeleteBucketCors) || ($.eventName = DeleteBucketLifecycle) || ($.eventName = DeleteBucketReplication)) }"
      description = "Monitoring changes to S3 bucket policies may reduce time to detect and correct permissive policies on sensitive S3 buckets."
    }


    AWSConfigChanges = {
      pattern     = "{ ($.eventSource = config.amazonaws.com) && (($.eventName=StopConfigurationRecorder)||($.eventName=DeleteDeliveryChannel)||($.eventName=PutDeliveryChannel)||($.eventName=PutConfigurationRecorder)) }"
      description = "Monitoring changes to AWS Config configuration will help ensure sustained visibility of configuration items within the AWS account."
    }

    SecurityGroupChanges = {
      pattern     = "{ ($.eventName = AuthorizeSecurityGroupIngress) || ($.eventName = AuthorizeSecurityGroupEgress) || ($.eventName = RevokeSecurityGroupIngress) || ($.eventName = RevokeSecurityGroupEgress) || ($.eventName = CreateSecurityGroup) || ($.eventName = DeleteSecurityGroup)}"
      description = "Monitoring changes to security group will help ensure that resources and services are not unintentionally exposed."
    }

    NACLChanges = {
      pattern     = "{ ($.eventName = CreateNetworkAcl) || ($.eventName = CreateNetworkAclEntry) || ($.eventName = DeleteNetworkAcl) || ($.eventName = DeleteNetworkAclEntry) || ($.eventName = ReplaceNetworkAclEntry) || ($.eventName = ReplaceNetworkAclAssociation) }"
      description = "Monitoring changes to NACLs will help ensure that AWS resources and services are not unintentionally exposed."
    }

    NetworkGWChanges = {
      pattern     = "{ ($.eventName = CreateCustomerGateway) || ($.eventName = DeleteCustomerGateway) || ($.eventName = AttachInternetGateway) || ($.eventName = CreateInternetGateway) || ($.eventName = DeleteInternetGateway) || ($.eventName = DetachInternetGateway) }"
      description = "Monitoring changes to network gateways will help ensure that all ingress/egress traffic traverses the VPC border via a controlled path."
    }

    RouteTableChanges = {
      pattern     = "{ ($.eventName = CreateRoute) || ($.eventName = CreateRouteTable) || ($.eventName = ReplaceRoute) || ($.eventName = ReplaceRouteTableAssociation) || ($.eventName = DeleteRouteTable) || ($.eventName = DeleteRoute) || ($.eventName = DisassociateRouteTable) }"
      description = "Monitoring changes to route tables will help ensure that all VPC traffic flows through an expected path."
    }

    VPCChanges = {
      pattern     = "{ ($.eventName = CreateVpc) || ($.eventName = DeleteVpc) || ($.eventName = ModifyVpcAttribute) || ($.eventName = AcceptVpcPeeringConnection) || ($.eventName = CreateVpcPeeringConnection) || ($.eventName = DeleteVpcPeeringConnection) || ($.eventName = RejectVpcPeeringConnection) || ($.eventName = AttachClassicLinkVpc) || ($.eventName = DetachClassicLinkVpc) || ($.eventName = DisableVpcClassicLink) || ($.eventName = EnableVpcClassicLink) }"
      description = "Monitoring changes to VPC will help ensure that all VPC traffic flows through an expected path."
    }

  }

  prefix   = ""
  controls = { for k, v in local.all_controls : k => v if !contains(var.disabled_controls, k) }
}

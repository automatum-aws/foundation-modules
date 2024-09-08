# Network Module
Provisions a VPC with:
1. A /16 CIDR range, with 9 or 12 (depending on number of AZs availible) /20 subnets (for public, private and secure).
2. Gateway endpoints for DynamoDB and S3.
3. Routing tables and NACLs that implements Automatum's public, private and secure subnet methodology.
4. NAT Gateways with Elastic IP Addresses for the private subnets.


## Input Variables
Check out `variables.tf` for a comprehensive list of variables and defaults. At the time of writing here are the ideal required variables in an example instantiation:
```hcl
module "vpc" {
    source = "path/to/this/module"
    naming_prefix = "customer-name" # Arbitrary prefix for all resources
    network_prefix = "10.0" # First 2 octets of VPC
}
```

## Outputs
Check `outputs.tf`

## Testing
See the _tests_ directory for a pre-made harness to see if the module plans/applies ok.

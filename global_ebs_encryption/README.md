# Global Default EBS Encryption Module
Baselines an account with EBS default encryption configuration globally.

## Region addition
A script that generates each region's resources from a teplate is located in _/src_

Example usage (from this module's directory):
```bash
for i in $(aws ec2 describe-regions --output text | awk '{print $4}'); do rm -rf config_$i.tf && ./src/template_gen.sh $i > ebs_enc_$i.tf; done
```

# AWS Config Module
Baselines an account with AWS Config configuration.

If `audit_account_id` is set to `"self"` it will configure resources needed by a parent (centralized) AWS Config recipient account.

## Region addition
A script that generates each region's resources from a teplate is located in _/src_

Example usage (from this module's directory):
```bash
for i in $(aws ec2 describe-regions --output text | awk '{print $4}'); do rm -rf config_$i.tf && ./src/template_gen.sh $i > config_$i.tf; done && rm config_ap-northeast-3.tf
```

**Note:** At this time ap-northeast-3 (Osaka) does not support multi region/account Config.

For the most recent list of supported resources see the AWS Config Docs [here](https://docs.aws.amazon.com/config/latest/developerguide/aggregate-data.html).

resource "aws_organizations_policy" "this" {
  name        = "aws-backup-policy-${var.region}"
  description = "${var.region} Backup Policy"
  type        = "BACKUP_POLICY"
  content     = <<CONTENT
{
  "plans": {
    "aws-backup-plan-${var.region}": {
      "regions": {
        "@@assign": [
          "${var.region}"
        ]
      },
      "rules": {
        "daily_backup": {
          "schedule_expression": {
            "@@assign": "${var.backup_cron_schedule.daily}"
          },
          "start_backup_window_minutes": {
            "@@assign": "60"
          },
          "complete_backup_window_minutes": {
            "@@assign": "180"
          },
          "target_backup_vault_name": {
            "@@assign": "AWSBackup"
          },
          "lifecycle": {
            "delete_after_days": {
              "@@assign": "30"
            }
          }
        },
        "weekly_backup": {
          "schedule_expression": {
            "@@assign": "${var.backup_cron_schedule.weekly}"
          },
          "start_backup_window_minutes": {
            "@@assign": "60"
          },
          "complete_backup_window_minutes": {
            "@@assign": "180"
          },
          "target_backup_vault_name": {
            "@@assign": "AWSBackup"
          },
          "lifecycle": {
            "delete_after_days": {
              "@@assign": "42"
            }
          }
        },
        "monthly_backup": {
          "schedule_expression": {
            "@@assign": "${var.backup_cron_schedule.monthly}"
          },
          "start_backup_window_minutes": {
            "@@assign": "60"
          },
          "complete_backup_window_minutes": {
            "@@assign": "180"
          },
          "target_backup_vault_name": {
            "@@assign": "AWSBackup"
          },
          "lifecycle": {
            "delete_after_days": {
              "@@assign": "366"
            }
          }
        },
        "yearly_backup": {
          "schedule_expression": {
            "@@assign": "${var.backup_cron_schedule.yearly}"
          },
          "start_backup_window_minutes": {
            "@@assign": "60"
          },
          "complete_backup_window_minutes": {
            "@@assign": "180"
          },
          "target_backup_vault_name": {
            "@@assign": "AWSBackup"
          },
          "lifecycle": {
            "delete_after_days": {
              "@@assign": "2555"
            }
          }
        }
      },
      "selections": {
        "tags": {
          "backup": {
            "iam_role_arn": {
              "@@assign": "arn:aws:iam::$account:role/${var.aws_backup_role_name}"
            },
            "tag_key": {
              "@@assign": "backup"
            },
            "tag_value": {
              "@@assign": [
                "true"
              ]
            }
          }
        }
      },
      "advanced_backup_settings": {
        "ec2": {
          "windows_vss": {
            "@@assign": "enabled"
          }
        }
      }
    }
  }
}
CONTENT
}

resource "aws_organizations_policy_attachment" "this" {
  for_each  = toset(var.organisational_units)
  policy_id = aws_organizations_policy.this.id
  target_id = each.value
}

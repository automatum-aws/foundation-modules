resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each = local.controls

  name           = "${local.prefix}${each.key}"
  pattern        = each.value["pattern"]
  log_group_name = lookup(each.value, "log_group_name", var.log_group_name)

  metric_transformation {
    name          = each.key
    namespace     = lookup(each.value, "namespace", var.namespace)
    value         = 1
    default_value = 0
  }
}

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = local.controls

  metric_name       = aws_cloudwatch_log_metric_filter.this[each.key].id
  namespace         = lookup(each.value, "namespace", var.namespace)
  alarm_name        = "${local.prefix}${each.key}"
  alarm_description = lookup(each.value, "description", null)

  actions_enabled           = lookup(each.value, "actions_enabled", var.actions_enabled)
  alarm_actions             = lookup(each.value, "alarm_actions", var.alarm_actions)
  ok_actions                = lookup(each.value, "ok_actions", null)
  insufficient_data_actions = lookup(each.value, "insufficient_data_actions", null)

  comparison_operator                   = lookup(each.value, "comparison_operator", "GreaterThanOrEqualToThreshold")
  evaluation_periods                    = lookup(each.value, "evaluation_periods", 1)
  threshold                             = lookup(each.value, "threshold", 1)
  unit                                  = lookup(each.value, "unit", null)
  datapoints_to_alarm                   = lookup(each.value, "datapoints_to_alarm", null)
  treat_missing_data                    = lookup(each.value, "treat_missing_data", "notBreaching")
  evaluate_low_sample_count_percentiles = lookup(each.value, "evaluate_low_sample_count_percentiles", null)

  period     = lookup(each.value, "period", 300)
  statistic  = lookup(each.value, "statistic", "Sum")
  dimensions = lookup(each.value, "dimensions", null)
}

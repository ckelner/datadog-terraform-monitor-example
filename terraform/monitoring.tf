#
# Datadog Monitor w/o Module
# https://www.terraform.io/docs/providers/datadog/r/monitor.html
#
resource "datadog_monitor" "cloudfront-test" {
  name = "DD Solutions Engineering Terraform Test"
  type = "query alert"
  query = "avg(last_5m):avg:aws.cloudfront.5xx_error_rate{aws_account:00000} > 5"
  require_full_window = false
  notify_no_data = false
  evaluation_delay = 900
  message = "Cloudfront 5xx error rate has increased in the last 5 minutes."
  thresholds {
    critical = 5
    warning = 3.5
    warning_recovery = 3.3
    critical_recovery = 3.3
  }
  tags = ["cake:test", "solutions-engineering", "kelner:hax"]
}

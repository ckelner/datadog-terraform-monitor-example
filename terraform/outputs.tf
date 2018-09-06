#############################################################################
# Outputs
# https://www.terraform.io/docs/configuration/outputs.html
#############################################################################
output "cloudfront-test" {
    value = "${datadog_monitor.cloudfront-test.id}"
}

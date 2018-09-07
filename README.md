# Datadog Terraform Monitor Example
Example of creating and updating a Datadog monitor using Terraform (for testing purposes).

Monitoring as Code w/ Terraform &amp; Datadog example. This repo will create
monitoring resources using Terraform.

__*This example was setup to test an issue with Terraform when making changes to
thresholds for a monitor that were not being applied and causing a permadiff
issue with TF state.*__

All terraform configuration can be found under the [`/terraform`](/terraform)
directory. Their is no hierarchy for this example, but typically you might
organize your terraform configuration in such a way that it gets broken into
re-usable modules (and potentially modules of modules) for common patterns
within your infrastructure.

__*This repo is only for example purposes.*__

If you are looking for examples that include infrastructure, please be sure to
check out the following:
- https://github.com/ckelner/terraform-datadog
- https://github.com/ckelner/terraform-intro-demo

This repo was carved from work done at Datadog:
https://github.com/DataDog/Miscellany/tree/master/create_monitor_terraform

# Noteworthy
- This repo does not use [Terraform
workspaces](https://www.terraform.io/docs/state/workspaces.html); it is a best
practice to use workspaces, this repo is only for example purposes.
- This repo does not use [Terraform remote
state](https://www.terraform.io/docs/state/remote.html); it is a best
practice to use remote state, this repo is only for example purposes.
- For monitoring definitions, see
[`./terraform/monitoring.tf`](./terraform/monitoring.tf)
- Monitors created through the Datadog API and Terraform have a specific syntax
that must include parameters for the critical threshold, e.g.
`avg(last_1h):sum:system.net.bytes_rcvd{host:host0} > 100` -- see more here:
https://www.terraform.io/docs/providers/datadog/r/monitor.html#query and here:
https://docs.datadoghq.com/api/?lang=python#create-a-monitor
  - Omitting or having this below the critical threshold will result in an error
  similar to this: `error updating monitor: API error 400 Bad Request: {"errors":["Critical threshold (0.9) does not match that used in the query (0.0)."]}`

# Use
## Setup
- Checkout this repository using git
- Change into the [`/terraform`](/terraform) directory on the command line
- Update variable values in [`/terraform/variables.tf`](/terraform/variables.tf)
to meet those required by your environment
- Define `DATADOG_API_KEY` and `DATADOG_APP_KEY` in environment variables per
the [Terraform
documentation](https://www.terraform.io/docs/providers/datadog/index.html)

## Init
Run `terraform init` - this will pull down all modules and setup your
local environment to get started with terraform. Output will look similar to the
example below (truncated in places):
```
Initializing provider plugins...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.datadog: version = "~> 1.2"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

# Plan
Run `terraform plan -out=plan.out` - this will provide you with a plan of what
terraform will change (commonly known as a "dry run"). The `-out` flag allows us
to save this plan to a file and use it when making the actual changes later. In
this way we can ensure that any local or remote changes that have occurred
between the time we ran `plan` and `apply` are not accepted.

An example of plan output (truncated in places):
```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + datadog_monitor.cloudfront-test
      id:                           <computed>
      evaluation_delay:             "900"
      include_tags:                 "true"
      message:                      "Cloudfront 5xx error rate has increased in the last 5 minutes."
      name:                         "DD Solutions Engineering Terraform Test"
      new_host_delay:               <computed>
      notify_no_data:               "false"
      query:                        "avg(last_5m):avg:aws.cloudfront.5xx_error_rate{aws_account:00000} > 5"
      require_full_window:          "false"
      tags.#:                       "3"
      tags.0:                       "cake:test"
      tags.1:                       "solutions-engineering"
      tags.2:                       "kelner:hax"
      thresholds.%:                 "4"
      thresholds.critical:          "5"
      thresholds.critical_recovery: "3.4"
      thresholds.warning:           "3.5"
      thresholds.warning_recovery:  "3.4"
      type:                         "query alert"


Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

This plan was saved to: plan.out

To perform exactly these actions, run the following command to apply:
    terraform apply "plan.out"
```

# Apply
Run `terraform apply "plan.out"` to create or update your infrastructure. By
passing `"plan.out"` this will ensure that what you saw in your dry run is what
gets applied to real resources in your provider (Datadog) ignoring any local or
remote changes (which can result in failure if there is a mismatch, this can
help you prevent mistakes or collisions). Example output below w/ truncations:
```
datadog_monitor.cloudfront-test: Creating...
  evaluation_delay:             "" => "900"
  include_tags:                 "" => "true"
  message:                      "" => "Cloudfront 5xx error rate has increased in the last 5 minutes."
  name:                         "" => "DD Solutions Engineering Terraform Test"
  new_host_delay:               "" => "<computed>"
  notify_no_data:               "" => "false"
  query:                        "" => "avg(last_5m):avg:aws.cloudfront.5xx_error_rate{aws_account:00000} > 5"
  require_full_window:          "" => "false"
  tags.#:                       "0" => "3"
  tags.0:                       "" => "cake:test"
  tags.1:                       "" => "solutions-engineering"
  tags.2:                       "" => "kelner:hax"
  thresholds.%:                 "0" => "4"
  thresholds.critical:          "" => "5"
  thresholds.critical_recovery: "" => "3.4"
  thresholds.warning:           "" => "3.5"
  thresholds.warning_recovery:  "" => "3.4"
  type:                         "" => "query alert"
datadog_monitor.cloudfront-test: Creation complete after 0s (ID: 6246701)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

cloudfront-test = 6246701
```

You can then take these IDs and open them in the Datadog UI:
- `https://app.datadoghq.com/monitors/<id from out>` replacing `<id from out>`
with the actual id at the end of the TF apply.

# Change and Plan again
Without making any changes, running `terraform plan -out=plan.out` should result
in a `No changes` result.
```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

datadog_monitor.cloudfront-test: Refreshing state... (ID: 6246701)

------------------------------------------------------------------------

No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your
configuration and real physical resources that exist. As a result, no
actions need to be performed.
```

Make some change to threshold values (e.g. changing `warning_recovery` and
`critical_recovery` from `3.5` to `3.3`) should result in this output:
```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

datadog_monitor.cloudfront-test: Refreshing state... (ID: 6246701)

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  ~ datadog_monitor.cloudfront-test
      thresholds.critical_recovery: "3.4" => "3.3"
      thresholds.warning_recovery:  "3.4" => "3.3"


Plan: 0 to add, 1 to change, 0 to destroy.

------------------------------------------------------------------------

This plan was saved to: plan.out

To perform exactly these actions, run the following command to apply:
    terraform apply "plan.out"
```

Upon running `terraform apply "plan.out"` again, you should see successful
in-place changes as seen below:
```
datadog_monitor.cloudfront-test: Modifying... (ID: 6246701)
  thresholds.critical_recovery: "3.4" => "3.3"
  thresholds.warning_recovery:  "3.4" => "3.3"
datadog_monitor.cloudfront-test: Modifications complete after 0s (ID: 6246701)

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

Outputs:

cloudfront-test = 6246701
```

# Modifying the Monitor out of band
If a resource is modified out of band (through some means that is not terraform,
e.g. Datadog UI, API, or third party library) when running `terraform plan`
again (without making any changes to the terraform configuration itself) you
will see that the plan wants to make changes as seen in the animated gif below:

![img](https://github.com/ckelner/datadog-terraform-monitor-example/blob/master/monitor_tf.gif)

Terraform will try set the monitor resource to the state it believes it should be
as defined in the configuration. When using tools like Terraform, they cannot
account for changes that happen outside it's scope, so if changes are made out of
band (UI, API, etc) Terraform will revert them to match the configuration defined
in your codebase.

# Destroy
Run `terraform destroy` to delete all your resources. Ideally you should, in a
best practices scenario, run a `plan -destroy -out=<file.out>` as described in
the [Terraform
docs](https://www.terraform.io/docs/commands/plan.html#destroy) to ensure you
do not destroy anything you intended to keep and then `apply` that plan.

Example output (truncated in places):
```
datadog_monitor.cloudfront-test: Refreshing state... (ID: 6246701)

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  - datadog_monitor.cloudfront-test


Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

datadog_monitor.cloudfront-test: Destroying... (ID: 6246701)
datadog_monitor.cloudfront-test: Destruction complete after 0s

Destroy complete! Resources: 1 destroyed.
```

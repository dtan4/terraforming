# Contributing

I love pull requests from everyone! By the way, I have a favor to ask you with your contribution.

## Making changes

- Currently, this gem supports only __AWS__ resources. Other providers are supported as separated gems.
  - Datadog: [terraforming-datadog](https://github.com/dtan4/terraforming-datadog)
  - DNSimple: [terraforming-dnsimple](https://github.com/dtan4/terraforming-dnsimple)
- Do not bump gem version in your pull request.
- Please follow the coding style of _existing_ code. Most of trivial rules can be checked by Rubocop ([`rubocop.yml`](https://github.com/dtan4/terraforming/blob/master/.rubocop.yml)).
- Please write tests for your changes. All tests are written with [RSpec](http://rspec.info/). In principle, I do not accept if the change decreases test coverage.

## Adding new resource

- Class name must match to Terraforming's resource name without `aws_` prefix, and be a complete resource name.
  - e.g. `aws_iam_group_membership`: `IAMGroupMembership`
  - Yes, I know that some of resources I added a long ago don't follow to this rule...
- File name must also match to Terraforming's resource name without `aws_` prefix.
  - e.g. `aws_iam_group_membership`: `iam_group_membership.rb`
- Command name should be abbreviation.
  - e.g. `aws_iam_group_membership`: `iamgp`
- Please check generation result by executing `terraform plan` with real resources. There should be NO diff with generated `.tf` and `.tfstate`.

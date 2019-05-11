# [v0.18.0](https://github.com/dtan4/terraforming/releases/tag/v0.18.0) (2019-05-11)

## Resource

- AWS DynamoDB table [#440](https://github.com/dtan4/terraforming/pull/440) (thanks @laxmiprasanna-gunna)

## Fixed / Updated

- Rename symbol of DynamoDB [#457](https://github.com/dtan4/terraforming/pull/457)
- Add IPv6 support to AWS Security Group (`terraforming sg`) [#438](https://github.com/dtan4/terraforming/pull/438) (thanks @babbottscott)
- Render notification_topic_arn when exporting ElastiCache clusters [#436](https://github.com/dtan4/terraforming/pull/436) (thanks @mozamimy)
- Fix nil check of AWS IAM instance profiles (`terraforming iamip`) [#415](https://github.com/dtan4/terraforming/pull/415) (thanks @savankumargudaas)

## Fixed / Updated

- Support Ruby from 2.3 to 2.6
- Support the latest EFS client [#453](https://github.com/dtan4/terraforming/pull/453)
- Fix cross-account security group reference [#389](https://github.com/dtan4/terraforming/pull/389) (thanks @seren)

# [v0.17.0](https://github.com/dtan4/terraforming/releases/tag/v0.17.0) (2019-04-21)

## Fixed / Updated

- Support Ruby from 2.3 to 2.6
- Support the latest EFS client [#453](https://github.com/dtan4/terraforming/pull/453)
- Fix cross-account security group reference [#389](https://github.com/dtan4/terraforming/pull/389) (thanks @seren)

# [v0.16.0](https://github.com/dtan4/terraforming/releases/tag/v0.16.0) (2017-10-23)

- Declare supported Terraform version: v0.9.3 or higher

## New feature

- Support assuming role `--assume` [#379](https://github.com/dtan4/terraforming/pull/379) (thanks @cmedley)

## Fixed / Updated

- Use ENCRYPT_DECRYPT as KMS key usage [#380](https://github.com/dtan4/terraforming/pull/380)
- Fix IAM instance profile [#376](https://github.com/dtan4/terraforming/pull/376) (thanks @chroju)

# [v0.15.0](https://github.com/dtan4/terraforming/releases/tag/v0.15.0) (2017-09-18)

## Fixed / Updated

- Upgrade to AWS SDK for Ruby V3 [#364](https://github.com/dtan4/terraforming/pull/364)
- Ignore external key by `terraforming kmsk` (KMS key) [#363](https://github.com/dtan4/terraforming/pull/363)
- Add failover attributes to Route53 record [#357](https://github.com/dtan4/terraforming/pull/357) (thanks @chroju)

# [v0.14.0](https://github.com/dtan4/terraforming/releases/tag/v0.14.0) (2017-08-05)

## Fixed / Updated

- Drop Ruby 2.1 from CI [#351](https://github.com/dtan4/terraforming/pull/351)
- Add `icmp_code` and `icmp_type` to NACL [#350](https://github.com/dtan4/terraforming/pull/350)
- Use aws-sdk [#349](https://github.com/dtan4/terraforming/pull/349)
- Rename title of aws_route53_record with wildcard [#348](https://github.com/dtan4/terraforming/pull/348) (thanks @furhouse)
- SNS Support [#332](https://github.com/dtan4/terraforming/pull/332) (thanks @uberblah)
  - `terraforming snst` (SNS Topic), `terraforming snss` (SNS Subscription)
- Fix typo in cli.rb [#329](https://github.com/dtan4/terraforming/pull/329) (thanks @slalFe)

# [v0.13.2](https://github.com/dtan4/terraforming/releases/tag/v0.13.2) (2017-04-20)

## Fixed / Updated

- Add prefix lists to security groups configuration [#326](https://github.com/dtan4/terraforming/pull/326) (thanks @julia-stripe)
- Support Ruby 2.4 without warnings [#323](https://github.com/dtan4/terraforming/pull/323)
- Fix support for EIP in EC2-Classic [#316](https://github.com/dtan4/terraforming/pull/316) (thanks @yn)

# [v0.13.1](https://github.com/dtan4/terraforming/releases/tag/v0.13.1) (2017-01-23)

## Fixed / Updated

- Fixes for route53_records [#303](https://github.com/dtan4/terraforming/pull/303) (thanks @mioi)
  - use `weighted_routing_policy`
  - add various routing policy (latency, geolocation)
  - uniquify resource name

# [v0.13.0](https://github.com/dtan4/terraforming/releases/tag/v0.13.0) (2017-01-12)

## Resource

- AWS KMS Key Alias [#300](https://github.com/dtan4/terraforming/pull/300)
- AWS KMS Key [#299](https://github.com/dtan4/terraforming/pull/299)

## Fixed / Updated

- Normalize all resource names in tf and tfstate files [#296](https://github.com/dtan4/terraforming/pull/296) (thanks @nabarunchatterjee)

# [v0.12.0](https://github.com/dtan4/terraforming/releases/tag/v0.12.0) (2016-12-20)

## Resource

- AWS ALB [#291](https://github.com/dtan4/terraforming/pull/291)
- AWS EFS File System [#283](https://github.com/dtan4/terraforming/pull/283) (thanks @notjames)

## Fixed / Updated

- Fix associate_public_ip_address attr for EC2 [#287](https://github.com/dtan4/terraforming/pull/287) (thanks @diwaniuk)

# [v0.11.0](https://github.com/dtan4/terraforming/releases/tag/v0.11.0) (2016-11-14)

## Resource

- AWS CloudWatch alarm [#273](https://github.com/dtan4/terraforming/pull/273) (thanks @eredi93)

## Fixed / Updated

- Remove native extension gems and use wrapper gem [#275](https://github.com/dtan4/terraforming/pull/275)
- Generate `iops` field only with io1 volume [#271](https://github.com/dtan4/terraforming/pull/271)
- Set `force_destroy: false` for IAM users [#267](https://github.com/dtan4/terraforming/pull/267) (thanks @raylu)
- Remove commands to delete empty files in export in README.md [#261](https://github.com/dtan4/terraforming/pull/261) (thanks @benmanns)

# [v0.10.0](https://github.com/dtan4/terraforming/releases/tag/v0.10.0) (2016-08-24)

## Resource

- AWS NAT Gateway [#240](https://github.com/dtan4/terraforming/pull/240) (thanks @brianknight10)

## Fixed / Updated

- Use the latest Oj (2.17.x) [#257](https://github.com/dtan4/terraforming/pull/257)
- Use the latest aws-sdk (2.5.x) [#256](https://github.com/dtan4/terraforming/pull/256)
- Attach AWS-scoped IAM policy attachments [#251](https://github.com/dtan4/terraforming/pull/251) (thanks @raylu)
- Fix LaunchConfiguration tf result when associate_public_ip_address [#250](https://github.com/dtan4/terraforming/pull/250) (thanks @gotyoooo)
- Paginate IAM Group Membership [#248](https://github.com/dtan4/terraforming/pull/248) (thanks @raylu)
- Add option to use AWS bundled CA certificate [#246](https://github.com/dtan4/terraforming/pull/246) (thanks @mattgartman)
- Fix network_interface naming in EIP [#243](https://github.com/dtan4/terraforming/pull/243)
- Fix name of "iampa" subcommand in CLI help output [#237](https://github.com/dtan4/terraforming/pull/237) (thanks @jimmycuadra)
- Paginate all resources [#236](https://github.com/dtan4/terraforming/pull/236) (thanks @philsnow)

__NOTE:__ OpsWorks support was omitted at v0.10.0 due to lack of tests. See [#264](https://github.com/dtan4/terraforming/pull/264) in detail.

## Others

- Introduce [RuboCop](https://github.com/bbatsov/rubocop) and [SideCI](https://sideci.com/) to check coding style automatically [#242](https://github.com/dtan4/terraforming/pull/242)

# [v0.9.1](https://github.com/dtan4/terraforming/releases/tag/v0.9.1) (2016-06-17)

## Fixed / Updated

- Fix Ox load error #229 (thanks @winebarrel)

# [v0.9.0](https://github.com/dtan4/terraforming/releases/tag/v0.9.0) (2016-06-12)

## Resource

- AWS IAM Policy Attachment #225

## Fixed / Updated

- Add `access_logs` attribute to ELB #223
- Add `internal` attribute to ELB #221 (thanks @kbruner)

# [v0.8.0](https://github.com/dtan4/terraforming/releases/tag/v0.8.0) (2016-05-29)

## Notice

- Drop Ruby 2.0 support. Now Terraforming supports Ruby 2.1 or higher. #206

## Resource

- AWS VPN Gateway #190 (thanks @tmccabe07)
- AWS Launch Configuration #187 (thanks @phoolish)
- AWS SQS #169 (thanks @manabusakai)

## Fixed / Updated

- Add prefix not to duplicate IAM inline policy name #212 (thanks @stormbeta)
- Use the latest Ox and Oj #210
- Simplify Security Group name #207 (thanks @woohgit)
- Include description field for IAM policies #203 (thanks @stormbeta)
- Support paging paging for IAM resources #201 (thanks @dominis)
- Fix Security Group output around EC2-Classic #200 (thanks @woohgit)
- Default Route53 record weight should be "-1" #197 (thanks @woohgit)
- Add Elasticache Redis port #189 (thanks @phoolish)
- Add `--region` option #188 (thanks @hajhatten)
- Add zsh completion #176 (thanks @knakayama)
- Add subnet ID to the resource name #185 (thanks @bandesz)
- Add EC2 placement group #180 (thanks @wsh)
- Wrap tag name in ELB #179 (thanks @robatwave)
- Retrive full list of AutoScaling Groups #170 (thanks @shouyu)

# [v0.7.0](https://github.com/dtan4/terraforming/releases/tag/v0.7.0) (2016-02-16)

## Resource

- AWS Internet Gateway #164 (thanks @manabusakai)
- AWS Redshift #161 (thanks @manabusakai)

## Fixed

- Modify AutoScaling Group tags format #167
- Support paging for Route53 records #160 (thanks @seanodonnell)
- Support paging for IAM user call #157 (thanks @crazed)

# [v0.6.2](https://github.com/dtan4/terraforming/releases/tag/v0.6.2) (2015-12-11)

## Fixed

- Get zone comment of Route53 Zone #149 (thanks @tjend)
- Skip implicit Route Table Association when generating tfstate #148 (thanks @kovyrin)
- Improve Route Table support #146 (thanks @kovyrin)
- Ignore EC2 source_dest_check if nil #143 (thanks @cmcarthur)

# [v0.6.1](https://github.com/dtan4/terraforming/releases/tag/v0.6.1) (2015-11-27)

## Fixed

- Fix wildcard record format of Route53 Record #139 (thanks @k1LoW)

# [v0.6.0](https://github.com/dtan4/terraforming/releases/tag/v0.6.0) (2015-11-21)

## Resource

- AWS Route Table Association #138 (thanks @k1LoW)

# [v0.5.0](https://github.com/dtan4/terraforming/releases/tag/v0.5.0) (2015-11-20)

## Resource

- AWS Route Table #137 (thanks @k1LoW)

# [v0.4.0](https://github.com/dtan4/terraforming/releases/tag/v0.4.0) (2015-11-10)

## New feature

- Add `--profile` option to read credential profile #135 (thanks @k1LoW)

## Resource

- AWS AutoScaling Group #134

# [v0.3.2](https://github.com/dtan4/terraforming/releases/tag/v0.3.2) (2015-10-06)

## Fixed

- Exclude iops field from EC2 instance tf with standard block device #132

# [v0.3.1](https://github.com/dtan4/terraforming/releases/tag/v0.3.1) (2015-09-24)

## Fixed

- Export EC2 instance monitoring state #130 (thanks @ngs)

# [v0.3.0](https://github.com/dtan4/terraforming/releases/tag/v0.3.0) (2015-08-23)

## Resource

- AWS Network Interface #127 (thanks @sakazuki)
- AWS Elastic IP #124 (thanks @sakazuki)

## Fixed

- Normalize module name of IAM user #129

# [v0.2.0](https://github.com/dtan4/terraforming/releases/tag/v0.2.0) (2015-08-22)

## New feature

- Add `--overwrite` option to overwrite existing `terraform.tfstate` #117

## Fixed

- Export S3 buckets only in the same region #121
- Exclude DB security group with empty ingress rules #120
- Include associated VPC parameters in Route53 hosted zone #119
- Support Route53 hosted zone with empty delegation set #118

# [v0.1.6](https://github.com/dtan4/terraforming/releases/tag/v0.1.6) (2015-08-10)

### Fixed

- Stop including ElastiCache port at any time #112

# [v0.1.5](https://github.com/dtan4/terraforming/releases/tag/v0.1.5) (2015-08-10)

### Updated

- Support S3 bucket policy #110

# [v0.1.4](https://github.com/dtan4/terraforming/releases/tag/v0.1.4) (2015-08-07)

### Fixed

- Refactor internal implements to reduce code #106
- Add tests and improvement for Security Group #105

# [v0.1.3](https://github.com/dtan4/terraforming/releases/tag/v0.1.3) (2015-08-01)

### Fixed

- Generate correct tf and tfstate if EC2 instance has no attached EBS #104
- Generate correct tfstate of Security Group #101 (thanks @grosendorf)

# [v0.1.2](https://github.com/dtan4/terraforming/releases/tag/v0.1.2) (2015-07-30)

### Fixed

- Generate correct tf and tfstate of EC2 #94, #102
- Handle multiple Route53 record types #99 (thanks @nicgrayson)
- Generate correct tfstate of ELB #91 (thanks @grosendorf)

# [v0.1.1](https://github.com/dtan4/terraforming/releases/tag/v0.1.1) (2015-07-14)

### Resource

- AWS ElastiCache Cluster
- AWS ElastiCache Subnet Group
- AWS IAM Group Membership

# [v0.1.0](https://github.com/dtan4/terraforming/releases/tag/v0.1.0) (2015-06-20)

### New feature

- `--merge TFSTATE_PATH` option: Merge generated tfstate to specified `terraform.tfstate`

### Fixed

- ELB must include either AZs or Subnets
- Include AWS Network ACL subnet ids

### Resource

- AWS IAM instance profile
- AWS IAM role
- AWS IAM role policy

# [v0.0.5](https://github.com/dtan4/terraforming/releases/tag/v0.0.5) (2015-06-01)

### Fixed

- Quote tag name #59

# [v0.0.4](https://github.com/dtan4/terraforming/releases/tag/v0.0.4) (2015-05-29)

### Fixed

- Generate tfstate `modules` as Hash #56 (thanks @endemics)
- Set unique module name to SecurityGroup #53
- Remove `owner_id` argument from SecurityGroup #54

# [v0.0.3](https://github.com/dtan4/terraforming/releases/tag/v0.0.3) (2015-05-26)

### Fixed

- Include AWS ELB additional attributes #39

### Resource

- AWS IAM group
- AWS IAM group policy
- AWS IAM policy
- AWS IAM user
- AWS IAM user policy
- AWS Route53 hosted zone
- AWS Route53 record

# [v0.0.2](https://github.com/dtan4/terraforming/releases/tag/v0.0.2) (2015-05-09)

### Fixed

- Nested module declation #35
  - raised NameError exception #34

### Resource

- AWS Network ACL

# [v0.0.1](https://github.com/dtan4/terraforming/releases/tag/v0.0.1) (2015-04-23)

Initial release.

### Resource

- AWS Database Parameter Group
- AWS Database Security Group
- AWS Subnet Group
- AWS EC2 instances
- AWS ELB
- AWS RDS instances
- AWS S3 buckets
- AWS SecurityGroup
- AWS Subnet
- AWS VPC

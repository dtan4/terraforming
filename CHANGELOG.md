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

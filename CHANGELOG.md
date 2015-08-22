# [v0.2.0](https://github.com/dtan4/terraforming/releases/tag/v0.2.0) (2015-08-22)

## New feature

- Add `--overwrite` option to overwrite existing `terraform.tfstate` #117

## Fixed

- Export S3 buckets only in the same region #121
- Exclude DB security group with empty ingress rules #120
- Include associated VPC parameters in Route53 hosted zone #119
- Support Route53 hosted zone with empty delegation set #118

### Fixed

- Stop including ElastiCache port at any time #112

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

# Terraforming

[![Build Status](https://travis-ci.org/dtan4/terraforming.svg?branch=master)](https://travis-ci.org/dtan4/terraforming)
[![Code Climate](https://codeclimate.com/github/dtan4/terraforming/badges/gpa.svg)](https://codeclimate.com/github/dtan4/terraforming)
[![Coverage Status](https://coveralls.io/repos/github/dtan4/terraforming/badge.svg?branch=increase-test-cov-160528)](https://coveralls.io/github/dtan4/terraforming)
[![Gem Version](https://badge.fury.io/rb/terraforming.svg)](http://badge.fury.io/rb/terraforming)
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)
[![Docker Repository on Quay.io](https://quay.io/repository/dtan4/terraforming/status "Docker Repository on Quay.io")](https://quay.io/repository/dtan4/terraforming)
[![Join the chat at https://gitter.im/dtan4/terraforming](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/dtan4/terraforming?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Export existing AWS resources to [Terraform](https://terraform.io/) style (tf, tfstate)

- [Supported version](#supported-version)
- [Installation](#installation)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
  -  [Export tf](#export-tf)
  -  [Export tfstate](#export-tfstate)
    -  [Example: Export all](#example-export-all)
- [Run as Docker container](#run-as-docker-container-)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Supported version

- Ruby 2.3 or higher is required
- Terraform v0.9.3 or higher is recommended
  - Some resources (e.g. `iam_instance_profile`) uses newer resource specification

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'terraforming'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install terraforming

## Prerequisites

You need to set AWS credentials.

```bash
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
export AWS_REGION=xx-yyyy-0
```

You can also specify credential profile in `~/.aws/credentials` by `--profile` option.

```bash
$ cat ~/.aws/credentials
[hoge]
aws_access_key_id = Hoge
aws_secret_access_key = FugaFuga

# Pass profile name by --profile option
$ terraforming s3 --profile hoge
```

You can assume a role by using the `--assume` option.

```bash
$ terraforming s3 --assume arn:aws:iam::123456789123:role/test-role
```

You can force the AWS SDK to utilize the CA certificate that is bundled with the SDK for systems where the default OpenSSL certificate is not installed (e.g. Windows) by utilizing the `--use-bundled-cert` option.

```bash
PS C:\> terraforming ec2 --use-bundled-cert
```

## Usage

```bash
$ terraforming
Commands:
  terraforming alb             # ALB
  terraforming asg             # AutoScaling Group
  terraforming cwa             # CloudWatch Alarm
  terraforming dbpg            # Database Parameter Group
  terraforming dbsg            # Database Security Group
  terraforming dbsn            # Database Subnet Group
  terraforming ddb             # DynamoDB
  terraforming ec2             # EC2
  terraforming ecc             # ElastiCache Cluster
  terraforming ecsn            # ElastiCache Subnet Group
  terraforming efs             # EFS File System
  terraforming eip             # EIP
  terraforming elb             # ELB
  terraforming help [COMMAND]  # Describe available commands or one specific command
  terraforming iamg            # IAM Group
  terraforming iamgm           # IAM Group Membership
  terraforming iamgp           # IAM Group Policy
  terraforming iamip           # IAM Instance Profile
  terraforming iamp            # IAM Policy
  terraforming iampa           # IAM Policy Attachment
  terraforming iamr            # IAM Role
  terraforming iamrp           # IAM Role Policy
  terraforming iamu            # IAM User
  terraforming iamup           # IAM User Policy
  terraforming igw             # Internet Gateway
  terraforming kmsa            # KMS Key Alias
  terraforming kmsk            # KMS Key
  terraforming lc              # Launch Configuration
  terraforming nacl            # Network ACL
  terraforming nat             # NAT Gateway
  terraforming nif             # Network Interface
  terraforming r53r            # Route53 Record
  terraforming r53z            # Route53 Hosted Zone
  terraforming rds             # RDS
  terraforming rs              # Redshift
  terraforming rt              # Route Table
  terraforming rta             # Route Table Association
  terraforming s3              # S3
  terraforming sg              # Security Group
  terraforming sn              # Subnet
  terraforming snst            # SNS Topic
  terraforming snss            # SNS Subscription
  terraforming sqs             # SQS
  terraforming vgw             # VPN Gateway
  terraforming vpc             # VPC

Options:
  [--merge=MERGE]                                # tfstate file to merge
  [--overwrite], [--no-overwrite]                # Overwrite existng tfstate
  [--tfstate], [--no-tfstate]                    # Generate tfstate
  [--profile=PROFILE]                            # AWS credentials profile
  [--region=REGION]                              # AWS region
  [--use-bundled-cert], [--no-use-bundled-cert]  # Use the bundled CA certificate from AWS SDK
```

### Export tf

```bash
$ terraforming <resource> [--profile PROFILE]
```

(e.g. S3 buckets):

```bash
$ terraforming s3
```

```hcl
resource "aws_s3_bucket" "hoge" {
    bucket = "hoge"
    acl    = "private"
}

resource "aws_s3_bucket" "fuga" {
    bucket = "fuga"
    acl    = "private"
}
```

### Export tfstate

```bash
$ terraforming <resource> --tfstate [--merge TFSTATE_PATH] [--overwrite] [--profile PROFILE]
```

(e.g. S3 buckets):

```bash
$ terraforming s3 --tfstate
```

```json
{
  "version": 1,
  "serial": 1,
  "modules": {
    "path": [
      "root"
    ],
    "outputs": {
    },
    "resources": {
      "aws_s3_bucket.hoge": {
        "type": "aws_s3_bucket",
        "primary": {
          "id": "hoge",
          "attributes": {
            "acl": "private",
            "bucket": "hoge",
            "id": "hoge"
          }
        }
      },
      "aws_s3_bucket.fuga": {
        "type": "aws_s3_bucket",
        "primary": {
          "id": "fuga",
          "attributes": {
            "acl": "private",
            "bucket": "fuga",
            "id": "fuga"
          }
        }
      }
    }
  }
}
```

If you want to merge exported tfstate to existing `terraform.tfstate`, specify `--tfstate --merge=/path/to/terraform.tfstate` option.
You can overwrite existing `terraform.tfstate` by specifying `--overwrite` option together.

Existing `terraform.tfstate`:

```bash
# /path/to/terraform.tfstate

{
  "version": 1,
  "serial": 88,
  "remote": {
    "type": "s3",
    "config": {
      "bucket": "terraforming-tfstate",
      "key": "tf"
    }
  },
  "modules": {
    "path": [
      "root"
    ],
    "outputs": {
    },
    "resources": {
      "aws_elb.hogehoge": {
        "type": "aws_elb",
        "primary": {
          "id": "hogehoge",
          "attributes": {
            "availability_zones.#": "2",
            "connection_draining": "true",
            "connection_draining_timeout": "300",
            "cross_zone_load_balancing": "true",
            "dns_name": "hoge-12345678.ap-northeast-1.elb.amazonaws.com",
            "health_check.#": "1",
            "id": "hogehoge",
            "idle_timeout": "60",
            "instances.#": "1",
            "listener.#": "1",
            "name": "hoge",
            "security_groups.#": "2",
            "source_security_group": "default",
            "subnets.#": "2"
          }
        }
      }
    }
  }
}
```

To generate merged tfstate:

```bash
$ terraforming s3 --tfstate --merge=/path/to/tfstate
```

```json
{
  "version": 1,
  "serial": 89,
  "remote": {
    "type": "s3",
    "config": {
      "bucket": "terraforming-tfstate",
      "key": "tf"
    }
  },
  "modules": {
    "path": [
      "root"
    ],
    "outputs": {
    },
    "resources": {
      "aws_elb.hogehoge": {
        "type": "aws_elb",
        "primary": {
          "id": "hogehoge",
          "attributes": {
            "availability_zones.#": "2",
            "connection_draining": "true",
            "connection_draining_timeout": "300",
            "cross_zone_load_balancing": "true",
            "dns_name": "hoge-12345678.ap-northeast-1.elb.amazonaws.com",
            "health_check.#": "1",
            "id": "hogehoge",
            "idle_timeout": "60",
            "instances.#": "1",
            "listener.#": "1",
            "name": "hoge",
            "security_groups.#": "2",
            "source_security_group": "default",
            "subnets.#": "2"
          }
        }
      },
      "aws_s3_bucket.hoge": {
        "type": "aws_s3_bucket",
        "primary": {
          "id": "hoge",
          "attributes": {
            "acl": "private",
            "bucket": "hoge",
            "id": "hoge"
          }
        }
      },
      "aws_s3_bucket.fuga": {
        "type": "aws_s3_bucket",
        "primary": {
          "id": "fuga",
          "attributes": {
            "acl": "private",
            "bucket": "fuga",
            "id": "fuga"
          }
        }
      }
    }
  }
}
```

After writing exported tf and tfstate to files, execute `terraform plan` and check the result.
There should be no diff.

```bash
$ terraform plan
No changes. Infrastructure is up-to-date. This means that Terraform
could not detect any differences between your configuration and
the real physical resources that exist. As a result, Terraform
doesn't need to do anything.
```

#### Example: Export all
Example assuming you want to export everything from us-west-2 and you are using ~/.aws/credentials with a `default` profile
```bash
export AWS_REGION=us-west-2
terraforming help | grep terraforming | grep -v help | awk '{print "terraforming", $2, "--profile", "default", ">", $2".tf";}' | bash
# find files that only have 1 empty line (likely nothing in AWS)
find . -type f -name '*.tf' | xargs wc -l | grep ' 1 .'
```

### Caveats

- `terraforming kmsk` does not export EXTERNAL origin key, bacause Terraform does not support it.

## Run as Docker container [![Docker Repository on Quay.io](https://quay.io/repository/dtan4/terraforming/status "Docker Repository on Quay.io")](https://quay.io/repository/dtan4/terraforming)

Terraforming Docker Image is available at [quay.io/dtan4/terraforming](https://quay.io/repository/dtan4/terraforming) and developed at [dtan4/dockerfile-terraforming](https://github.com/dtan4/dockerfile-terraforming).

Pull the Docker image:

```bash
$ docker pull quay.io/dtan4/terraforming:latest
```

And then run Terraforming as a Docker container:

```bash
$ docker run \
    --rm \
    --name terraforming \
    -e AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXX \
    -e AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
    -e AWS_REGION=xx-yyyy-0 \
    quay.io/dtan4/terraforming:latest \
    terraforming s3
```

## Development

After checking out the repo, run `script/setup` to install dependencies. Then, run `script/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Please read [Contribution Guide](CONTRIBUTING.md) at first.

1. Fork it ( https://github.com/dtan4/terraforming/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)

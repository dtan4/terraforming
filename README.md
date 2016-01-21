# Terraforming

[![Build Status](https://travis-ci.org/dtan4/terraforming.svg?branch=master)](https://travis-ci.org/dtan4/terraforming)
[![Code Climate](https://codeclimate.com/github/dtan4/terraforming/badges/gpa.svg)](https://codeclimate.com/github/dtan4/terraforming)
[![Test Coverage](https://codeclimate.com/github/dtan4/terraforming/badges/coverage.svg)](https://codeclimate.com/github/dtan4/terraforming)
[![Dependency Status](https://gemnasium.com/dtan4/terraforming.svg)](https://gemnasium.com/dtan4/terraforming)
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
- [Run as Docker container](#run-as-docker-container-)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Supported version

Ruby 2.x

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

## Usage

```bash
$ terraforming
Commands:
  terraforming asg             # AutoScaling Group
  terraforming dbpg            # Database Parameter Group
  terraforming dbsg            # Database Security Group
  terraforming dbsn            # Database Subnet Group
  terraforming ec2             # EC2
  terraforming ecc             # ElastiCache Cluster
  terraforming ecsn            # ElastiCache Subnet Group
  terraforming elb             # ELB
  terraforming iamg            # IAM Group
  terraforming iamgm           # IAM Group Membership
  terraforming iamgp           # IAM Group Policy
  terraforming iamip           # IAM Instance Profile
  terraforming iamp            # IAM Policy
  terraforming iamr            # IAM Role
  terraforming iamrp           # IAM Role Policy
  terraforming iamu            # IAM User
  terraforming iamup           # IAM User Policy
  terraforming nacl            # Network ACL
  terraforming r53r            # Route53 Record
  terraforming r53z            # Route53 Hosted Zone
  terraforming rds             # RDS
  terraforming rt              # Route Table
  terraforming rta             # Route Table Association
  terraforming s3              # S3
  terraforming sg              # Security Group
  terraforming sn              # Subnet
  terraforming vpc             # VPC
```

### Export tf

```bash
$ terraforming <resource> [--profile PROFILE]
```

(e.g. S3 buckets):

```bash
$ terraforming s3
```

```go
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

1. Fork it ( https://github.com/dtan4/terraforming/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)

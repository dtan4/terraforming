# Terraforming

[![Build Status](https://travis-ci.org/dtan4/terraforming.svg?branch=master)](https://travis-ci.org/dtan4/terraforming)
[![Code Climate](https://codeclimate.com/github/dtan4/terraforming/badges/gpa.svg)](https://codeclimate.com/github/dtan4/terraforming)
[![Test Coverage](https://codeclimate.com/github/dtan4/terraforming/badges/coverage.svg)](https://codeclimate.com/github/dtan4/terraforming)

Export existing AWS resources to [Terraform](https://terraform.io/) style (tf, tfstate)

## Prerequisites

- [AWS Command Line Interface (awscli)](http://aws.amazon.com/cli/?nc2=h_ls)

## Usage

### Database Parameter Group

```bash
$ aws rds describe-db-parameters | terraforming db-pg [--tfstate]
```

### Database Security Group

```bash
$ aws rds describe-db-security-groups | terraforming db-sg [--tfstate]
```

### Database Subnet Group

```bash
$ aws rds describe-db-subnet-groups | terraforming db-subnet [--tfstate]
```

### EC2

```bash
$ aws ec2 describe-instances | terraforming ec2 [--tfstate]
```

### ELB

```bash
$ aws elb describe-load-balancers | terraforming elb [--tfstate]
```

### RDS

```bash
$ aws rds describe-db-instances | terraforming rds [--tfstate]
```

### S3

```bash
$ aws s3api list-buckets | terraforming s3 [--tfstate]
```

### Security Group

```bash
$ aws ec2 describe-security-groups | terraforming sg [--tfstate]
```

### VPC

```bash
$ aws ec2 describe-vpcs | terraforming vpc [--tfstate]
```

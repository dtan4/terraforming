# Terraforming

[![Build Status](https://travis-ci.org/dtan4/terraforming.svg?branch=master)](https://travis-ci.org/dtan4/terraforming)
[![Code Climate](https://codeclimate.com/github/dtan4/terraforming/badges/gpa.svg)](https://codeclimate.com/github/dtan4/terraforming)
[![Test Coverage](https://codeclimate.com/github/dtan4/terraforming/badges/coverage.svg)](https://codeclimate.com/github/dtan4/terraforming)

Export existing AWS resources to [Terraform](https://terraform.io/) style (tf, tfstate)

## Prerequisites

You need to set AWS credentials.

```bash
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=
```

## Usage

### Database Parameter Group

```bash
$ terraforming dbpg [--tfstate]
```

### Database Security Group

```bash
$ terraforming dbsg [--tfstate]
```

### Database Subnet Group

```bash
$ terraforming dbsn [--tfstate]
```

### (TODO) EC2

```bash
$ terraforming ec2 [--tfstate]
```

### ELB

```bash
$ terraforming elb [--tfstate]
```

### RDS

```bash
$ terraforming rds [--tfstate]
```

### S3

```bash
$ terraforming s3 [--tfstate]
```

### (TODO) Security Group

```bash
$ terraforming sg [--tfstate]
```

### (TODO) VPC

```bash
$ terraforming vpc [--tfstate]
```

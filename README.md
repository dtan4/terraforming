# terraforming
Convert existing AWS resource to tfstate

## Prerequisites

- [AWS Command Line Interface (awscli)](http://aws.amazon.com/cli/?nc2=h_ls)

## Usage

### RDS

```bash
$ aws rds describe-db-instances | ./terraforming-rds
```

### S3

```bash
$ aws s3api list-buckets | ./terraforming-s3
```

module Terraforming
  class CLI < Thor
    desc "dbpg", "Database Parameter Group"
    option :tfstate, type: :boolean
    def dbpg
      execute(Terraforming::Resource::DBParameterGroup, options)
    end

    desc "dbsg", "Database Security Group"
    option :tfstate, type: :boolean
    def dbsg
      execute(Terraforming::Resource::DBSecurityGroup, options)
    end

    desc "dbsn", "Database Subnet Group"
    option :tfstate, type: :boolean
    def dbsn
      execute(Terraforming::Resource::DBSubnetGroup, options)
    end

    desc "ec2", "EC2"
    option :tfstate, type: :boolean
    def ec2
      execute(Terraforming::Resource::EC2, options)
    end

    desc "elb", "ELB"
    option :tfstate, type: :boolean
    def elb
      execute(Terraforming::Resource::ELB, options)
    end

    desc "nacl", "Network ACL"
    option :tfstate, type: :boolean
    def nacl
      execute(Terraforming::Resource::NetworkACL, options)
    end

    desc "rds", "RDS"
    option :tfstate, type: :boolean
    def rds
      execute(Terraforming::Resource::RDS, options)
    end

    desc "s3", "S3"
    option :tfstate, type: :boolean
    def s3
      execute(Terraforming::Resource::S3, options)
    end

    desc "sg", "SecurityGroup"
    option :tfstate, type: :boolean
    def sg
      execute(Terraforming::Resource::SecurityGroup, options)
    end

    desc "vpc", "VPC"
    option :tfstate, type: :boolean
    def vpc
      execute(Terraforming::Resource::VPC, options)
    end

    private

    def execute(klass, options)
      puts options[:tfstate] ? klass.tfstate : klass.tf
    end
  end
end

module Terraforming
  class CLI < Thor
    desc "dbpg", "Database Parameter Group"
    option :tfstate, type: :boolean
    def dbpg
      puts options[:tfstate] ? Terraforming::Resource::DBParameterGroup.tfstate : Terraforming::Resource::DBParameterGroup.tf
    end

    desc "dbsg", "Database Security Group"
    option :tfstate, type: :boolean
    def dbsg
      puts options[:tfstate] ? Terraforming::Resource::DBSecurityGroup.tfstate : Terraforming::Resource::DBSecurityGroup.tf
    end

    desc "dbsubnet", "Database Subnet Group"
    option :tfstate, type: :boolean
    def dbsubnet
      puts options[:tfstate] ? Terraforming::Resource::DBSubnetGroup.tfstate : Terraforming::Resource::DBSubnetGroup.tf
    end

    desc "elb", "ELB"
    option :tfstate, type: :boolean
    def elb
      puts options[:tfstate] ? Terraforming::Resource::ELB.tfstate : Terraforming::Resource::ELB.tf
    end

    desc "rds", "RDS"
    option :tfstate, type: :boolean
    def rds
      puts options[:tfstate] ? Terraforming::Resource::RDS.tfstate : Terraforming::Resource::RDS.tf
    end

    desc "s3", "S3"
    option :tfstate, type: :boolean
    def s3
      puts options[:tfstate] ? Terraforming::Resource::S3.tfstate : Terraforming::Resource::S3.tf
    end
  end
end

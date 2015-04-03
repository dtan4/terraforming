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

    desc "elb", "ELB"
    option :tfstate, type: :boolean
    def elb
      execute(Terraforming::Resource::ELB, options)
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

    private

    def execute(klass, options)
      puts options[:tfstate] ? klass.tfstate : klass.tf
    end
  end
end

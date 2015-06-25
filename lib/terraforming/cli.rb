module Terraforming
  class CLI < Thor
    class_option :merge, type: :string, desc: "tfstate file to merge"
    class_option :tfstate, type: :boolean, desc: "Generate tfstate"

    desc "dbpg", "Database Parameter Group"
    def dbpg
      execute(Terraforming::Resource::DBParameterGroup, options)
    end

    desc "dbsg", "Database Security Group"
    def dbsg
      execute(Terraforming::Resource::DBSecurityGroup, options)
    end

    desc "dbsn", "Database Subnet Group"
    def dbsn
      execute(Terraforming::Resource::DBSubnetGroup, options)
    end

    desc "ec2", "EC2"
    def ec2
      execute(Terraforming::Resource::EC2, options)
    end

    desc "ecc", "ElastiCache Cluster"
    def ecc
      execute(Terraforming::Resource::ElastiCacheCluster, options)
    end

    desc "elb", "ELB"
    def elb
      execute(Terraforming::Resource::ELB, options)
    end

    desc "iamg", "IAM Group"
    def iamg
      execute(Terraforming::Resource::IAMGroup, options)
    end

    desc "iamgp", "IAM Group Policy"
    def iamgp
      execute(Terraforming::Resource::IAMGroupPolicy, options)
    end

    desc "iamip", "IAM Instance Profile"
    def iamip
      execute(Terraforming::Resource::IAMInstanceProfile, options)
    end

    desc "iamp", "IAM Policy"
    def iamp
      execute(Terraforming::Resource::IAMPolicy, options)
    end

    desc "iamr", "IAM Role"
    def iamr
      execute(Terraforming::Resource::IAMRole, options)
    end

    desc "iamrp", "IAM Role Policy"
    def iamrp
      execute(Terraforming::Resource::IAMRolePolicy, options)
    end

    desc "iamu", "IAM User"
    def iamu
      execute(Terraforming::Resource::IAMUser, options)
    end

    desc "iamup", "IAM User Policy"
    def iamup
      execute(Terraforming::Resource::IAMUserPolicy, options)
    end

    desc "nacl", "Network ACL"
    def nacl
      execute(Terraforming::Resource::NetworkACL, options)
    end

    desc "r53r", "Route53 Record"
    def r53r
      execute(Terraforming::Resource::Route53Record, options)
    end

    desc "r53z", "Route53 Hosted Zone"
    def r53z
      execute(Terraforming::Resource::Route53Zone, options)
    end

    desc "rds", "RDS"
    def rds
      execute(Terraforming::Resource::RDS, options)
    end

    desc "s3", "S3"
    def s3
      execute(Terraforming::Resource::S3, options)
    end

    desc "sg", "Security Group"
    def sg
      execute(Terraforming::Resource::SecurityGroup, options)
    end

    desc "sn", "Subnet"
    def sn
      execute(Terraforming::Resource::Subnet, options)
    end

    desc "vpc", "VPC"
    def vpc
      execute(Terraforming::Resource::VPC, options)
    end

    private

    def execute(klass, options)
      result = if options[:tfstate]
                 tfstate(klass, options[:merge])
               else
                 klass.tf
               end

      puts result
    end

    def tfstate(klass, tfstate_path)
      return klass.tfstate unless tfstate_path

      tfstate_base = JSON.parse(open(tfstate_path).read)
      klass.tfstate(tfstate_base: tfstate_base)
    end
  end
end

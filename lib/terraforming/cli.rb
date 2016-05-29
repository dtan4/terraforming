module Terraforming
  class CLI < Thor
    class_option :merge, type: :string, desc: "tfstate file to merge"
    class_option :overwrite, type: :boolean, desc: "Overwrite existng tfstate"
    class_option :tfstate, type: :boolean, desc: "Generate tfstate"
    class_option :profile, type: :string, desc: "AWS credentials profile"
    class_option :region, type: :string, desc: "AWS region"

    desc "asg", "AutoScaling Group"
    def asg
      execute(Terraforming::Provider::AWS::Resource::AutoScalingGroup, options)
    end

    desc "dbpg", "Database Parameter Group"
    def dbpg
      execute(Terraforming::Provider::AWS::Resource::DBParameterGroup, options)
    end

    desc "dbsg", "Database Security Group"
    def dbsg
      execute(Terraforming::Provider::AWS::Resource::DBSecurityGroup, options)
    end

    desc "dbsn", "Database Subnet Group"
    def dbsn
      execute(Terraforming::Provider::AWS::Resource::DBSubnetGroup, options)
    end

    desc "ec2", "EC2"
    def ec2
      execute(Terraforming::Provider::AWS::Resource::EC2, options)
    end

    desc "ecc", "ElastiCache Cluster"
    def ecc
      execute(Terraforming::Provider::AWS::Resource::ElastiCacheCluster, options)
    end

    desc "ecsn", "ElastiCache Subnet Group"
    def ecsn
      execute(Terraforming::Provider::AWS::Resource::ElastiCacheSubnetGroup, options)
    end

    desc "eip", "EIP"
    def eip
      execute(Terraforming::Provider::AWS::Resource::EIP, options)
    end

    desc "elb", "ELB"
    def elb
      execute(Terraforming::Provider::AWS::Resource::ELB, options)
    end

    desc "iamg", "IAM Group"
    def iamg
      execute(Terraforming::Provider::AWS::Resource::IAMGroup, options)
    end

    desc "iamgm", "IAM Group Membership"
    def iamgm
      execute(Terraforming::Provider::AWS::Resource::IAMGroupMembership, options)
    end

    desc "iamgp", "IAM Group Policy"
    def iamgp
      execute(Terraforming::Provider::AWS::Resource::IAMGroupPolicy, options)
    end

    desc "iamip", "IAM Instance Profile"
    def iamip
      execute(Terraforming::Provider::AWS::Resource::IAMInstanceProfile, options)
    end

    desc "iamp", "IAM Policy"
    def iamp
      execute(Terraforming::Provider::AWS::Resource::IAMPolicy, options)
    end

    desc "iamr", "IAM Role"
    def iamr
      execute(Terraforming::Provider::AWS::Resource::IAMRole, options)
    end

    desc "iamrp", "IAM Role Policy"
    def iamrp
      execute(Terraforming::Provider::AWS::Resource::IAMRolePolicy, options)
    end

    desc "iamu", "IAM User"
    def iamu
      execute(Terraforming::Provider::AWS::Resource::IAMUser, options)
    end

    desc "iamup", "IAM User Policy"
    def iamup
      execute(Terraforming::Provider::AWS::Resource::IAMUserPolicy, options)
    end

    desc "lc", "Launch Configuration"
    def lc
      execute(Terraforming::Provider::AWS::Resource::LaunchConfiguration, options)
    end

    desc "igw", "Internet Gateway"
    def igw
      execute(Terraforming::Provider::AWS::Resource::InternetGateway, options)
    end

    desc "nacl", "Network ACL"
    def nacl
      execute(Terraforming::Provider::AWS::Resource::NetworkACL, options)
    end

    desc "nif", "Network Interface"
    def nif
      execute(Terraforming::Provider::AWS::Resource::NetworkInterface, options)
    end

    desc "r53r", "Route53 Record"
    def r53r
      execute(Terraforming::Provider::AWS::Resource::Route53Record, options)
    end

    desc "r53z", "Route53 Hosted Zone"
    def r53z
      execute(Terraforming::Provider::AWS::Resource::Route53Zone, options)
    end

    desc "rds", "RDS"
    def rds
      execute(Terraforming::Provider::AWS::Resource::RDS, options)
    end

    desc "rs", "Redshift"
    def rs
      execute(Terraforming::Provider::AWS::Resource::Redshift, options)
    end

    desc "rt", "Route Table"
    def rt
      execute(Terraforming::Provider::AWS::Resource::RouteTable, options)
    end

    desc "rta", "Route Table Association"
    def rta
      execute(Terraforming::Provider::AWS::Resource::RouteTableAssociation, options)
    end

    desc "s3", "S3"
    def s3
      execute(Terraforming::Provider::AWS::Resource::S3, options)
    end

    desc "sg", "Security Group"
    def sg
      execute(Terraforming::Provider::AWS::Resource::SecurityGroup, options)
    end

    desc "sn", "Subnet"
    def sn
      execute(Terraforming::Provider::AWS::Resource::Subnet, options)
    end

    desc "sqs", "SQS"
    def sqs
      execute(Terraforming::Provider::AWS::Resource::SQS, options)
    end

    desc "vpc", "VPC"
    def vpc
      execute(Terraforming::Provider::AWS::Resource::VPC, options)
    end

    desc "vgw", "VPN Gateway"
    def vgw
      execute(Terraforming::Provider::AWS::Resource::VPNGateway, options)
    end


    private

    def execute(klass, options)
      Aws.config[:credentials] = Aws::SharedCredentials.new(profile_name: options[:profile]) if options[:profile]
      Aws.config[:region] = options[:region] if options[:region]
      result = options[:tfstate] ? tfstate(klass, options[:merge]) : tf(klass)

      if options[:tfstate] && options[:merge] && options[:overwrite]
        open(options[:merge], "w+") do |f|
          f.write(result)
          f.flush
        end
      else
        puts result
      end
    end

    def tf(klass)
      klass.tf
    end

    def tfstate(klass, tfstate_path)
      tfstate = tfstate_path ? JSON.parse(open(tfstate_path).read) : tfstate_skeleton
      tfstate["serial"] = tfstate["serial"] + 1
      tfstate["modules"][0]["resources"] = tfstate["modules"][0]["resources"].merge(klass.tfstate)
      JSON.pretty_generate(tfstate)
    end

    def tfstate_skeleton
      {
        "version" => 1,
        "serial" => 0,
        "modules" => [
          {
            "path" => [
              "root"
            ],
            "outputs" => {},
            "resources" => {},
          }
        ]
      }
    end
  end
end

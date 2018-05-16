module Terraforming
  class CLI < Thor
    OPTIONS_AVAILABLE_TO_SUBCOMMANDS = [
        Terraforming::Resource::SecurityGroup::AVAILABLE_OPTIONS,
    ].reduce(:concat).freeze

    class_option :merge, type: :string, desc: "tfstate file to merge"
    class_option :overwrite, type: :boolean, desc: "Overwrite existing tfstate"
    class_option :tfstate, type: :boolean, desc: "Generate tfstate"
    class_option :profile, type: :string, desc: "AWS credentials profile"
    class_option :region, type: :string, desc: "AWS region"
    class_option :assume, type: :string, desc: "Role ARN to assume"
    class_option :use_bundled_cert,
                 type: :boolean,
                 desc: "Use the bundled CA certificate from AWS SDK"

    desc "alb", "ALB"
    def alb
      execute(Terraforming::Resource::ALB, options)
    end

    desc "asg", "AutoScaling Group"
    def asg
      execute(Terraforming::Resource::AutoScalingGroup, options)
    end

    desc "cwa", "CloudWatch Alarm"
    def cwa
      execute(Terraforming::Resource::CloudWatchAlarm, options)
    end

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

    desc "ecsn", "ElastiCache Subnet Group"
    def ecsn
      execute(Terraforming::Resource::ElastiCacheSubnetGroup, options)
    end

    desc "eip", "EIP"
    def eip
      execute(Terraforming::Resource::EIP, options)
    end

    desc "efs", "EFS File System"
    def efs
      execute(Terraforming::Resource::EFSFileSystem, options)
    end

    desc "elb", "ELB"
    def elb
      execute(Terraforming::Resource::ELB, options)
    end

    desc "iamg", "IAM Group"
    def iamg
      execute(Terraforming::Resource::IAMGroup, options)
    end

    desc "iamgm", "IAM Group Membership"
    def iamgm
      execute(Terraforming::Resource::IAMGroupMembership, options)
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

    desc "iampa", "IAM Policy Attachment"
    def iampa
      execute(Terraforming::Resource::IAMPolicyAttachment, options)
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

    desc "kmsa", "KMS Key Alias"
    def kmsa
      execute(Terraforming::Resource::KMSAlias, options)
    end

    desc "kmsk", "KMS Key"
    def kmsk
      execute(Terraforming::Resource::KMSKey, options)
    end

    desc "lc", "Launch Configuration"
    def lc
      execute(Terraforming::Resource::LaunchConfiguration, options)
    end

    desc "igw", "Internet Gateway"
    def igw
      execute(Terraforming::Resource::InternetGateway, options)
    end

    desc "nacl", "Network ACL"
    def nacl
      execute(Terraforming::Resource::NetworkACL, options)
    end

    desc "nat", "NAT Gateway"
    def nat
      execute(Terraforming::Resource::NATGateway, options)
    end

    desc "nif", "Network Interface"
    def nif
      execute(Terraforming::Resource::NetworkInterface, options)
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

    desc "rs", "Redshift"
    def rs
      execute(Terraforming::Resource::Redshift, options)
    end

    desc "rt", "Route Table"
    def rt
      execute(Terraforming::Resource::RouteTable, options)
    end

    desc "rta", "Route Table Association"
    def rta
      execute(Terraforming::Resource::RouteTableAssociation, options)
    end

    desc "s3", "S3"
    def s3
      execute(Terraforming::Resource::S3, options)
    end

    desc "sg", "Security Group"
    method_option :"group-ids", type: :array, desc: "Filter exported security groups by IDs"
    def sg
      execute(Terraforming::Resource::SecurityGroup, options)
    end

    desc "sn", "Subnet"
    def sn
      execute(Terraforming::Resource::Subnet, options)
    end

    desc "sqs", "SQS"
    def sqs
      execute(Terraforming::Resource::SQS, options)
    end

    desc "vpc", "VPC"
    def vpc
      execute(Terraforming::Resource::VPC, options)
    end

    desc "vgw", "VPN Gateway"
    def vgw
      execute(Terraforming::Resource::VPNGateway, options)
    end

    desc "snst", "SNS Topic"
    def snst
      execute(Terraforming::Resource::SNSTopic, options)
    end

    desc "snss", "SNS Subscription"
    def snss
      execute(Terraforming::Resource::SNSTopicSubscription, options)
    end

    private

    def configure_aws(options)
      Aws.config[:credentials] = Aws::SharedCredentials.new(profile_name: options[:profile]) if options[:profile]
      Aws.config[:region] = options[:region] if options[:region]

      if options[:assume]
        args = { role_arn: options[:assume], role_session_name: "terraforming-session-#{Time.now.to_i}" }
        args[:client] = Aws::STS::Client.new(profile: options[:profile]) if options[:profile]
        Aws.config[:credentials] = Aws::AssumeRoleCredentials.new(args)
      end

      Aws.use_bundled_cert! if options[:use_bundled_cert]
    end

    def execute(klass, options)
      configure_aws(options)

      subcommand_options = options.select { |k, v| OPTIONS_AVAILABLE_TO_SUBCOMMANDS.include? k }
      result = if options[:tfstate]
                 tfstate(klass, options[:merge], subcommand_options)
               else
                 tf(klass, subcommand_options)
               end

      if options[:tfstate] && options[:merge] && options[:overwrite]
        open(options[:merge], "w+") do |f|
          f.write(result)
          f.flush
        end
      else
        puts result
      end
    end

    def tf(klass, options={})
      if options.empty?
        klass.tf
      else
        klass.tf(options)
      end
    end

    def tfstate(klass, tfstate_path, options={})
      tfstate = tfstate_path ? MultiJson.load(open(tfstate_path).read) : tfstate_skeleton
      tfstate["serial"] = tfstate["serial"] + 1
      tfstate_addition = if options.empty?
                           klass.tfstate
                         else
                           klass.tfstate(options)
                         end
      tfstate["modules"][0]["resources"] = tfstate["modules"][0]["resources"].merge(tfstate_addition)
      MultiJson.encode(tfstate, pretty: true)
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

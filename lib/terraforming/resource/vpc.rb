module Terraforming
  module Resource
    class VPC
      include Terraforming::Util

      def self.tf(client: Aws::EC2::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::EC2::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/vpc")
      end

      def tfstate
        vpcs.inject({}) do |resources, vpc|
          attributes = {
            "cidr_block" => vpc.cidr_block,
            "enable_dns_hostnames" => enable_dns_hostnames?(vpc).to_s,
            "enable_dns_support" => enable_dns_support?(vpc).to_s,
            "id" => vpc.vpc_id,
            "instance_tenancy" => vpc.instance_tenancy,
            "tags.#" => vpc.tags.length.to_s,
          }
          resources["aws_vpc.#{module_name_of(vpc)}"] = {
            "type" => "aws_vpc",
            "primary" => {
              "id" => vpc.vpc_id,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def enable_dns_hostnames?(vpc)
        vpc_attribute(vpc, :enableDnsHostnames).enable_dns_hostnames.value
      end

      def enable_dns_support?(vpc)
        vpc_attribute(vpc, :enableDnsSupport).enable_dns_support.value
      end

      def module_name_of(vpc)
        normalize_module_name(name_from_tag(vpc, vpc.vpc_id))
      end

      def vpcs
        @client.describe_vpcs.map(&:vpcs).flatten
      end

      def vpc_attribute(vpc, attribute)
        @client.describe_vpc_attribute(vpc_id: vpc.vpc_id, attribute: attribute)
      end
    end
  end
end

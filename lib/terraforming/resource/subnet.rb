module Terraforming
  module Resource
    class Subnet
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
        apply_template(@client, "tf/subnet")
      end

      def tfstate
        subnets.inject({}) do |resources, subnet|
          attributes = {
            "availability_zone" => subnet.availability_zone,
            "cidr_block" => subnet.cidr_block,
            "id" => subnet.subnet_id,
            "map_public_ip_on_launch" => subnet.map_public_ip_on_launch.to_s,
            "tags.#" => subnet.tags.length.to_s,
            "vpc_id" => subnet.vpc_id,
          }
          resources["aws_subnet.#{module_name_of(subnet)}"] = {
            "type" => "aws_subnet",
            "primary" => {
              "id" => subnet.subnet_id,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def subnets
        @client.describe_subnets.map(&:subnets).flatten
      end

      def module_name_of(subnet)
        normalize_module_name("#{subnet.subnet_id}-#{name_from_tag(subnet, subnet.subnet_id)}")
      end
    end
  end
end

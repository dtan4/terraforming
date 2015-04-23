module Terraforming::Resource
  class Subnet
    include Terraforming::Util

    def self.tf(client = Aws::RDS::Client.new)
      self.new(client).tf
    end

    def self.tfstate(client = Aws::RDS::Client.new)
      self.new(client).tfstate
    end

    def initialize(client)
      @client = client
    end

    def tf
      apply_template(@client, "tf/subnet")
    end

    def tfstate
      resources = subnets.inject({}) do |result, subnet|
        attributes = {
          "availability_zone" => subnet.availability_zone,
          "cidr_block" => subnet.cidr_block,
          "id" => subnet.subnet_id,
          "map_public_ip_on_launch" => subnet.map_public_ip_on_launch.to_s,
          "tags.#" => subnet.tags.length.to_s,
          "vpc_id" => subnet.vpc_id,
        }
        result["aws_subnet.#{module_name_of(subnet)}"] = {
          "type" => "aws_subnet",
          "primary" => {
            "id" => subnet.subnet_id,
            "attributes" => attributes
          }
        }

        result
      end

      generate_tfstate(resources)
    end

    private

    def subnets
      @client.describe_subnets.subnets
    end

    def module_name_of(subnet)
      normalize_module_name(name_from_tag(subnet, subnet.subnet_id))
    end
  end
end
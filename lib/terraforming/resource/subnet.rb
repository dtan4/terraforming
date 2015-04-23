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
      resources = db_subnet_groups.inject({}) do |result, subnet_group|
        attributes = {
          "description" => subnet_group.db_subnet_group_description,
          "name" => subnet_group.db_subnet_group_name,
          "subnet_ids.#" => subnet_group.subnets.length.to_s
        }
        result["aws_db_subnet_group.#{module_name_of(subnet_group)}"] = {
          "type" => "aws_db_subnet_group",
          "primary" => {
            "id" => subnet_group.db_subnet_group_name,
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

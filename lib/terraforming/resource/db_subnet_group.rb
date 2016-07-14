module Terraforming
  module Resource
    class DBSubnetGroup
      include Terraforming::Util

      def self.tf(client: Aws::RDS::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::RDS::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/db_subnet_group")
      end

      def tfstate
        db_subnet_groups.inject({}) do |resources, subnet_group|
          attributes = {
            "description" => subnet_group.db_subnet_group_description,
            "name" => subnet_group.db_subnet_group_name,
            "subnet_ids.#" => subnet_group.subnets.length.to_s
          }
          resources["aws_db_subnet_group.#{module_name_of(subnet_group)}"] = {
            "type" => "aws_db_subnet_group",
            "primary" => {
              "id" => subnet_group.db_subnet_group_name,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def db_subnet_groups
        @client.describe_db_subnet_groups.map(&:db_subnet_groups).flatten
      end

      def module_name_of(subnet_group)
        normalize_module_name(subnet_group.db_subnet_group_name)
      end
    end
  end
end

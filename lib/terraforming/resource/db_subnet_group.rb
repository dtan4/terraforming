module Terraforming::Resource
  class DBSubnetGroup
    def self.tf(client = Aws::RDS::Client.new)
      Terraforming::Resource.apply_template(client, "tf/db_subnet_group")
    end

    def self.tfstate(client = Aws::RDS::Client.new)
      resources = client.describe_db_subnet_groups.db_subnet_groups.inject({}) do |result, subnet_group|
        attributes = {
          "description" => subnet_group.db_subnet_group_description,
          "name" => subnet_group.db_subnet_group_name,
          "subnet_ids.#" => subnet_group.subnets.length.to_s
        }
        result["aws_db_subnet_group.#{subnet_group.db_subnet_group_name}"] = {
          "type" => "aws_db_subnet_group",
          "primary" => {
            "id" => subnet_group.db_subnet_group_name,
            "attributes" => attributes
          }
        }

        result
      end

      tfstate = {
        "version" => 1,
        "serial" => 84,
        "modules" => {
          "path" => [
            "root"
          ],
          "outputs" => {},
          "resources" => resources
        }
      }

      JSON.pretty_generate(tfstate)
    end
  end
end

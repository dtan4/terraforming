module Terraforming::Resource
  class DBParameterGroup
    def self.tf(client = Aws::RDS::Client.new)
      Terraforming::Resource.apply_template(client, "tf/db_parameter_group")
    end

    def self.tfstate(client = Aws::RDS::Client.new)
      tfstate_db_parameter_groups =
        client.describe_db_parameter_groups.db_parameter_groups.inject({}) do |result, parameter_group|
        attributes = {
          "description" => parameter_group.description,
          "family" => parameter_group.db_parameter_group_family,
          "id" => parameter_group.db_parameter_group_name,
          "name" => parameter_group.db_parameter_group_name,
          "parameter.#" => client.describe_db_parameters(db_parameter_group_name: parameter_group.db_parameter_group_name).parameters.length.to_s
        }
        result["aws_db_parameter_group.#{parameter_group.db_parameter_group_name}"] = {
          "type" => "aws_db_parameter_group",
          "primary" => {
            "id" => parameter_group.db_parameter_group_name,
            "attributes" => attributes
          }
        }

        result
      end

      JSON.pretty_generate(tfstate_db_parameter_groups)
    end
  end
end

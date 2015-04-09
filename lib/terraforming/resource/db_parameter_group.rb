module Terraforming::Resource
  class DBParameterGroup
    def self.tf(client = Aws::RDS::Client.new)
      Terraforming::Resource.apply_template(client, "tf/db_parameter_group")
    end

    def self.tfstate(client = Aws::RDS::Client.new)
      resources = client.describe_db_parameter_groups.db_parameter_groups.inject({}) do |result, parameter_group|
        parameters = client.describe_db_parameters(db_parameter_group_name: parameter_group.db_parameter_group_name).parameters.inject({}) do |r, parameter|
          hashkey = "#{parameter.parameter_name}-#{parameter.parameter_value || ''}-"
          hashcode = Terraforming::Resource.hashcode(hashkey)
          r["parameter.#{hashcode}.name"] = parameter.parameter_name
          r["parameter.#{hashcode}.value"] = parameter.parameter_value || ""
          r["parameter.#{hashcode}.apply_method"] = parameter.apply_method || "immediate"
          r
        end

        attributes = {
          "description" => parameter_group.description,
          "family" => parameter_group.db_parameter_group_family,
          "id" => parameter_group.db_parameter_group_name,
          "name" => parameter_group.db_parameter_group_name,
          "parameter.#" => client.describe_db_parameters(db_parameter_group_name: parameter_group.db_parameter_group_name).parameters.length.to_s
        }.merge(parameters)
        result["aws_db_parameter_group.#{Terraforming::Resource.normalize_module_name(parameter_group.db_parameter_group_name)}"] = {
          "type" => "aws_db_parameter_group",
          "primary" => {
            "id" => parameter_group.db_parameter_group_name,
            "attributes" => attributes
          }
        }

        result
      end

      Terraforming::Resource.tfstate(resources)
    end
  end
end

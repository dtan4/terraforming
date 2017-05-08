module Terraforming
  module Resource
    class DBParameterGroup
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
        apply_template(@client, "tf/db_parameter_group")
      end

      def tfstate
        db_parameter_groups.inject({}) do |resources, parameter_group|
          attributes = {
            "description" => parameter_group.description,
            "family" => parameter_group.db_parameter_group_family,
            "id" => parameter_group.db_parameter_group_name,
            "name" => parameter_group.db_parameter_group_name,
            "parameter.#" => db_parameters_in(parameter_group).length.to_s
          }
          resources["aws_db_parameter_group.#{module_name_of(parameter_group)}"] = {
            "type" => "aws_db_parameter_group",
            "primary" => {
              "id" => parameter_group.db_parameter_group_name,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def db_parameter_groups
        marker = ""
        dbpgs = []

        loop do
          resp = @client.describe_db_parameter_groups(marker: marker)
          dbpgs += resp.db_parameter_groups
          marker = resp.marker
          break if marker.nil?
        end

        dbpgs
      end

      def db_parameters_in(parameter_group)
        marker = ""
        params = []

        loop do
          resp = @client.describe_db_parameters(db_parameter_group_name: parameter_group.db_parameter_group_name, marker: marker)
          params += resp.parameters
          marker = resp.marker
          break if marker.nil?
        end

        params
      end

      def module_name_of(parameter_group)
        normalize_module_name(parameter_group.db_parameter_group_name)
      end
    end
  end
end

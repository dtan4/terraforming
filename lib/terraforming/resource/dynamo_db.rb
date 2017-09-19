module Terraforming
  module Resource
    class DynamoDB
      include Terraforming::Util

      def self.tf(client: Aws::DynamoDB::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::DynamoDB::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/dynamo_db")
      end

      def tfstate
        tables.inject({}) do |resources, table|
          attributes = {
            "arn" => table.table_arn,
            "attribute.#" => table.attribute_definitions.length.to_s,
          }
          resources["aws_dynamodb_table.#{table.table_name}"] = {
            "type" => "aws_dynamodb_table",
            "depends_on": [], #TODO(potsbo): check this
            "primary": {
              "id": nil, #TODO(potsbo): write here
              "attributes": attributes,
              "meta": {},#TODO(potsbo): check this
              "tainted": false#TODO(potsbo): check this
            },
            "deposed": [],#TODO(potsbo): check this
            "provider": "",#TODO(potsbo): check this
          }
        end
      end

      def tables
        table_names = @client.list_tables.table_names
        table_names.map { |table| @client.describe_table(table_name: table).table }
      end
    end
  end
end

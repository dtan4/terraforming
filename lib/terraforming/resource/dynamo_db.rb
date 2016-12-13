module Terraforming
  module Resource
    class DynamoDB
      include Terraforming::Util

      def self.tf(client: Aws::DynamoDB::Client.new)
        self.new(client).tf
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/dynamo_db")
      end

      def tables
        table_names = @client.list_tables.table_names
        table_names.map { |table| @client.describe_table(table_name: table).table }
      end
    end
  end
end

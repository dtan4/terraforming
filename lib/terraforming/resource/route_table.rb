module Terraforming
  module Resource
    class RouteTable
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
        apply_template(@client, "tf/route_table")
      end

      def tfstate
        route_tables.inject({}) do |resources, route_table|
          attributes = {
            "id" => route_table.route_table_id,
            "route.#" => routes_of(route_table).length.to_s,
            "tags.#" => route_table.tags.length.to_s,
            "vpc_id" => route_table.vpc_id,
          }
          resources["aws_route_table.#{module_name_of(route_table)}"] = {
            "type" => "aws_route_table",
            "primary" => {
              "id" => route_table.route_table_id,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def routes_of(route_table)
        route_table.routes
      end

      def module_name_of(route_table)
        normalize_module_name(name_from_tag(route_table, route_table.route_table_id))
      end

      def route_tables
        @client.describe_route_tables.route_tables
      end
    end
  end
end

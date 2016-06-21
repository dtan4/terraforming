module Terraforming
  module Resource
    class RouteTableAssociation
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
        apply_template(@client, "tf/route_table_association")
      end

      def tfstate
        resources = {}
        route_tables.each do |route_table|
          associations_of(route_table).each do |assoc|
            attributes = {
              "id" => assoc.route_table_association_id,
              "route_table_id" => assoc.route_table_id,
              "subnet_id" => assoc.subnet_id,
            }

            resources["aws_route_table_association.#{module_name_of(route_table, assoc)}"] = {
              "type" => "aws_route_table_association",
              "primary" => {
                "id" => assoc.route_table_association_id,
                "attributes" => attributes
              }
            }
          end
        end
        resources
      end

      private

      def associations_of(route_table)
        route_table.associations.reject { |association| association.subnet_id.nil? }
      end

      def module_name_of(route_table, assoc)
        normalize_module_name(name_from_tag(route_table, route_table.route_table_id) + '-' + assoc.route_table_association_id)
      end

      def route_tables
        @client.describe_route_tables.map(&:route_tables).flatten
      end
    end
  end
end

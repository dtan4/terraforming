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
            "vpc_id" => route_table.vpc_id,
          }

          attributes.merge!(tags_attributes_of(route_table))
          attributes.merge!(routes_attributes_of(route_table))
          attributes.merge!(propagating_vgws_attributes_of(route_table))

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
        route_table.routes.reject do |route|
          route.gateway_id.to_s == 'local' ||
            route.origin.to_s == 'EnableVgwRoutePropagation' ||
            route.destination_prefix_list_id
        end
      end

      def module_name_of(route_table)
        normalize_module_name(name_from_tag(route_table, route_table.route_table_id))
      end

      def route_tables
        @client.describe_route_tables.map(&:route_tables).flatten
      end

      def routes_attributes_of(route_table)
        routes = routes_of(route_table)
        attributes = { "route.#" => routes.length.to_s }

        routes.each do |route|
          attributes.merge!(route_attributes_of(route))
        end

        attributes
      end

      def route_attributes_of(route)
        hashcode = route_hashcode_of(route)
        attributes = {
          "route.#{hashcode}.cidr_block" => route.destination_cidr_block.to_s,
          "route.#{hashcode}.gateway_id" => route.gateway_id.to_s,
          "route.#{hashcode}.instance_id" => route.instance_id.to_s,
          "route.#{hashcode}.network_interface_id" => route.network_interface_id.to_s,
          "route.#{hashcode}.vpc_peering_connection_id" => route.vpc_peering_connection_id.to_s
        }

        attributes
      end

      def route_hashcode_of(route)
        string = "#{route.destination_cidr_block}-#{route.gateway_id}-"
        instance_set = !route.instance_id.nil? && route.instance_id != ''

        string << route.instance_id.to_s if instance_set
        string << route.vpc_peering_connection_id.to_s
        string << route.network_interface_id.to_s unless instance_set

        Zlib.crc32(string)
      end

      def propagaving_vgws_of(route_table)
        route_table.propagating_vgws.map(&:gateway_id).map(&:to_s)
      end

      def propagating_vgws_attributes_of(route_table)
        vgws = propagaving_vgws_of(route_table)
        attributes = { "propagating_vgws.#" => vgws.length.to_s }

        vgws.each do |gateway_id|
          hashcode = Zlib.crc32(gateway_id)
          attributes["propagating_vgws.#{hashcode}"] = gateway_id
        end

        attributes
      end

      def tags_attributes_of(route_table)
        tags = route_table.tags
        attributes = { "tags.#" => tags.length.to_s }
        tags.each { |tag| attributes["tags.#{tag.key}"] = tag.value }
        attributes
      end
    end
  end
end

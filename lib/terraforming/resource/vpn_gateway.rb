module Terraforming
  module Resource
    class VPNGateway
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
        apply_template(@client, "tf/vpn_gateway")
      end

      def tfstate
        vpn_gateways.inject({}) do |resources, vpn_gateway|
          next resources if vpn_gateway.vpc_attachments.empty?

          attributes = {
            "id"     => vpn_gateway.vpn_gateway_id,
            "vpc_id" => vpn_gateway.vpc_attachments[0].vpc_id,
            "availability_zone" => vpn_gateway.availability_zone,
            "tags.#" => vpn_gateway.tags.length.to_s,
          }

          attributes.merge!(tags_attributes_of(vpn_gateway))
          resources["aws_vpn_gateway.#{module_name_of(vpn_gateway)}"] = {
            "type" => "aws_vpn_gateway",
            "primary" => {
              "id"         => vpn_gateway.vpn_gateway_id,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def tags_attributes_of(vpn_gateway)
        tags = vpn_gateway.tags
        attributes = { "tags.#" => tags.length.to_s }
        tags.each { |tag| attributes["tags.#{tag.key}"] = tag.value }
        attributes
      end

      def vpn_gateways
        @client.describe_vpn_gateways.vpn_gateways
      end

      def module_name_of(vpn_gateway)
        normalize_module_name(name_from_tag(vpn_gateway, vpn_gateway.vpn_gateway_id))
      end
    end
  end
end

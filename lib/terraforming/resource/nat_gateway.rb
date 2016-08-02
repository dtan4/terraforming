module Terraforming
  module Resource
    class NATGateway
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
        apply_template(@client, "tf/nat_gateway")
      end

      def tfstate
        nat_gateways.inject({}) do |resources, nat_gateway|
          next resources if nat_gateway.nat_gateway_addresses.empty?

          attributes = {
            "id" => nat_gateway.nat_gateway_id,
            "allocation_id" => nat_gateway.nat_gateway_addresses[0].allocation_id,
            "subnet_id" => nat_gateway.subnet_id,
            "network_inferface_id" => nat_gateway.nat_gateway_addresses[0].network_interface_id,
            "private_ip" => nat_gateway.nat_gateway_addresses[0].private_ip,
            "public_ip" => nat_gateway.nat_gateway_addresses[0].public_ip,
          }
          resources["aws_nat_gateway.#{module_name_of(nat_gateway)}"] = {
            "type" => "aws_nat_gateway",
            "primary" => {
              "id"         => nat_gateway.nat_gateway_id,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def nat_gateways
        @client.describe_nat_gateways.nat_gateways
      end

      def module_name_of(nat_gateway)
        normalize_module_name(nat_gateway.nat_gateway_id)
      end
    end
  end
end

module Terraforming
  module Resource
    class InternetGateway
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
        apply_template(@client, "tf/internet_gateway")
      end

      def tfstate
        internet_gateways.inject({}) do |resources, internet_gateway|
          next resources if internet_gateway.attachments.empty?

          attributes = {
            "id"     => internet_gateway.internet_gateway_id,
            "vpc_id" => internet_gateway.attachments[0].vpc_id,
            "tags.#" => internet_gateway.tags.length.to_s,
          }
          resources["aws_internet_gateway.#{module_name_of(internet_gateway)}"] = {
            "type" => "aws_internet_gateway",
            "primary" => {
              "id"         => internet_gateway.internet_gateway_id,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def internet_gateways
        @client.describe_internet_gateways.map(&:internet_gateways).flatten
      end

      def module_name_of(internet_gateway)
        normalize_module_name(name_from_tag(internet_gateway, internet_gateway.internet_gateway_id))
      end
    end
  end
end

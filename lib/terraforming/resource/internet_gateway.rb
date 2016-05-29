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

          attributes.merge!(tags_attributes_of(internet_gateway))
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

      def tags_attributes_of(internet_gateway)
        tags = internet_gateway.tags
        attributes = { "tags.#" => tags.length.to_s }
        tags.each { |tag| attributes["tags.#{tag.key}"] = tag.value }
        attributes
      end

      def internet_gateways
        @client.describe_internet_gateways.internet_gateways
      end

      def module_name_of(internet_gateway)
        normalize_module_name(name_from_tag(internet_gateway, internet_gateway.internet_gateway_id))
      end
    end
  end
end

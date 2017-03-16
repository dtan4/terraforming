module Terraforming
  module Resource
    class EIP
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
        apply_template(@client, "tf/eip")
      end

      def tfstate
        eips.inject({}) do |resources, addr|
          attributes = {
            "association_id" => addr.association_id,
            "domain" => addr.domain,
            "id" => vpc?(addr) ? addr.allocation_id : addr.public_ip,
            "instance" => addr.instance_id,
            "network_interface" => addr.network_interface_id,
            "private_ip" => addr.private_ip_address,
            "public_ip" => addr.public_ip,
            "vpc" => vpc?(addr).to_s,
          }
          attributes.delete_if { |_k, v| v.nil? }
          resources["aws_eip.#{module_name_of(addr)}"] = {
            "type" => "aws_eip",
            "primary" => {
              "id" => vpc?(addr) ? addr.allocation_id : addr.public_ip,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def eips
        @client.describe_addresses.map(&:addresses).flatten
      end

      def vpc?(addr)
        addr.domain.eql?("vpc")
      end

      def module_name_of(addr)
        if vpc?(addr)
          normalize_module_name(addr.allocation_id)
        else
          normalize_module_name(addr.public_ip)
        end
      end
    end
  end
end

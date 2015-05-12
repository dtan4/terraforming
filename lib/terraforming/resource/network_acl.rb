module Terraforming
  module Resource
    class NetworkACL
      include Terraforming::Util

      def self.tf(client = Aws::EC2::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client = Aws::EC2::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/network_acl")
      end

      def tfstate
        resources = network_acls.inject({}) do |result, network_acl|
          attributes = {
            "egress.#" => egresses_of(network_acl).length.to_s,
            "id" => network_acl.network_acl_id,
            "ingress.#" => ingresses_of(network_acl).length.to_s,
            "tags.#" => network_acl.tags.length.to_s,
            "vpc_id" => network_acl.vpc_id,
          }
          result["aws_network_acl.#{module_name_of(network_acl)}"] = {
            "type" => "aws_network_acl",
            "primary" => {
              "id" => network_acl.network_acl_id,
              "attributes" => attributes
            }
          }

          result
        end

        generate_tfstate(resources)
      end

      private

      def default_entry?(entry)
        entry.rule_number == default_rule_number
      end

      def default_rule_number
        32767
      end

      def egresses_of(network_acl)
        network_acl.entries.select { |entry| entry.egress && !default_entry?(entry) }
      end

      def from_port_of(entry)
        entry.port_range ? entry.port_range.from : 0
      end

      def ingresses_of(network_acl)
        network_acl.entries.select { |entry| !entry.egress && !default_entry?(entry) }
      end

      def module_name_of(network_acl)
        normalize_module_name(name_from_tag(network_acl, network_acl.network_acl_id))
      end

      def network_acls
        @client.describe_network_acls.network_acls
      end

      def to_port_of(entry)
        entry.port_range ? entry.port_range.to : 65535
      end
    end
  end
end

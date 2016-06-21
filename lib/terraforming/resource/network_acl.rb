module Terraforming
  module Resource
    class NetworkACL
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
        apply_template(@client, "tf/network_acl")
      end

      def tfstate
        network_acls.inject({}) do |resources, network_acl|
          attributes = {
            "egress.#" => egresses_of(network_acl).length.to_s,
            "id" => network_acl.network_acl_id,
            "ingress.#" => ingresses_of(network_acl).length.to_s,
            "subnet_ids.#" => subnet_ids_of(network_acl).length.to_s,
            "tags.#" => network_acl.tags.length.to_s,
            "vpc_id" => network_acl.vpc_id,
          }
          resources["aws_network_acl.#{module_name_of(network_acl)}"] = {
            "type" => "aws_network_acl",
            "primary" => {
              "id" => network_acl.network_acl_id,
              "attributes" => attributes
            }
          }

          resources
        end
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
        @client.describe_network_acls.map(&:network_acls).flatten
      end

      def subnet_ids_of(network_acl)
        network_acl.associations.map { |association| association.subnet_id }
      end

      def to_port_of(entry)
        entry.port_range ? entry.port_range.to : 0
      end
    end
  end
end

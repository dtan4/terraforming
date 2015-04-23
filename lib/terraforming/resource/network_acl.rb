module Terraforming::Resource
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
      resources = security_groups.inject({}) do |result, security_group|
        attributes = {
          "description" => security_group.description,
          "egress.#" => security_group.ip_permissions_egress.length.to_s,
          "id" => security_group.group_id,
          "ingress.#" => security_group.ip_permissions.length.to_s,
          "name" => security_group.group_name,
          "owner_id" => security_group.owner_id,
          "vpc_id" => security_group.vpc_id || "",
        }
        result["aws_security_group.#{module_name_of(security_group)}"] = {
          "type" => "aws_security_group",
          "primary" => {
            "id" => security_group.group_id,
            "attributes" => attributes
          }
        }

        result
      end

      generate_tfstate(resources)
    end

    private

    def egresses_of(network_acl)
      network_acl.entries.select { |entry| entry.egress }
    end

    def from_port_of(entry)
      entry.port_range ? entry.port_range.from : 0
    end

    def ingresses_of(network_acl)
      network_acl.entries.select { |entry| !entry.egress }
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

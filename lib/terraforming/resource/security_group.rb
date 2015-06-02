module Terraforming
  module Resource
    class SecurityGroup
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
        apply_template(@client, "tf/security_group")
      end

      def tfstate
        resources = security_groups.inject({}) do |result, security_group|
          attributes = {
            "description" => security_group.description,
            "id" => security_group.group_id,
            "name" => security_group.group_name,
            "owner_id" => security_group.owner_id,
            "vpc_id" => security_group.vpc_id || "",
          }

          attributes["egress.#"] = security_group.ip_permissions_egress.length.to_s

          security_group.ip_permissions_egress.each do |permission|
            hashcode = permission_hashcode_of(security_group, permission)
            attributes.merge!({
              "egress.#{hashcode}.from_port" => (permission.from_port || 0).to_s,
              "egress.#{hashcode}.to_port" => (permission.to_port || 0).to_s,
              "egress.#{hashcode}.protocol" => permission.ip_protocol,
              "egress.#{hashcode}.cidr_blocks.#" => permission.ip_ranges.length.to_s,
              "egress.#{hashcode}.security_groups.#" => permission.user_id_group_pairs.length.to_s,
              "egress.#{hashcode}.self" => self_referenced_permission?(security_group, permission).to_s,
            })
          end

          attributes["ingress.#"] = security_group.ip_permissions.length.to_s

          security_group.ip_permissions.each do |permission|
            hashcode = permission_hashcode_of(security_group, permission)
            attributes.merge!({
              "ingress.#{hashcode}.from_port" => (permission.from_port || 0).to_s,
              "ingress.#{hashcode}.to_port" => (permission.to_port || 0).to_s,
              "ingress.#{hashcode}.protocol" => permission.ip_protocol,
              "ingress.#{hashcode}.cidr_blocks.#" => permission.ip_ranges.length.to_s,
              "ingress.#{hashcode}.security_groups.#" => permission.user_id_group_pairs.length.to_s,
              "ingress.#{hashcode}.self" => self_referenced_permission?(security_group, permission).to_s,
            })
          end

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

      def module_name_of(security_group)
        normalize_module_name("#{security_group.group_id}-#{security_group.group_name}")
      end

      def permission_hashcode_of(security_group, permission)
        string =
          "#{permission.from_port}-" <<
          "#{permission.to_port}-" <<
          "#{permission.ip_protocol}-" <<
          "#{self_referenced_permission?(security_group, permission).to_s}-"

        permission.ip_ranges.each { |range| string << "#{range.cidr_ip}-" }
        security_groups_in(permission).each { |group| string << "#{group}-" }

        Zlib.crc32(string)
      end

      def self_referenced_permission?(security_group, permission)
        security_groups_in(permission).include?(security_group.group_id)
      end

      def security_groups
        @client.describe_security_groups.security_groups
      end

      def security_groups_in(permission)
        permission.user_id_group_pairs.map { |range| range.group_id }
      end
    end
  end
end

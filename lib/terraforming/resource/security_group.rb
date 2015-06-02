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

      def module_name_of(security_group)
        normalize_module_name("#{security_group.group_id}-#{security_group.group_name}")
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

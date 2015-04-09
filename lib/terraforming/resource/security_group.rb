module Terraforming::Resource
  class SecurityGroup
    def self.tf(client = Aws::EC2::Client.new)
      Terraforming::Resource.apply_template(client, "tf/security_group")
    end

    def self.tfstate(client = Aws::EC2::Client.new)
      resources =
        client.describe_security_groups.security_groups.inject({}) do |result, security_group|
        attributes = {
          "description" => security_group.description,
          "egress.#" => security_group.ip_permissions_egress.length.to_s,
          "id" => security_group.group_id,
          "ingress.#" => security_group.ip_permissions.length.to_s,
          "name" => security_group.group_name,
          "owner_id" => security_group.owner_id,
          "vpc_id" => security_group.vpc_id || "",
        }
        result["aws_security_group.#{Terraforming::Resource.normalize_module_name(security_group.group_name)}"] = {
          "type" => "aws_security_group",
          "primary" => {
            "id" => security_group.group_id,
            "attributes" => attributes
          }
        }

        result
      end

      Terraforming::Resource.tfstate(resources)
    end
  end
end

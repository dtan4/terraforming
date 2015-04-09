module Terraforming::Resource
  class DBSecurityGroup
    def self.tf(client = Aws::RDS::Client.new)
      Terraforming::Resource.apply_template(client, "tf/db_security_group")
    end

    def self.tfstate(client = Aws::RDS::Client.new)
      resources = client.describe_db_security_groups.db_security_groups.inject({}) do |result, security_group|
        attributes = {
          "db_subnet_group_name" => security_group.db_security_group_name,
          "id" => security_group.db_security_group_name,
          "ingress.#" => (security_group.ec2_security_groups.length + security_group.ip_ranges.length).to_s,
          "name" => security_group.db_security_group_name,
        }
        result["aws_db_security_group.#{security_group.db_security_group_name}"] = {
          "type" => "aws_db_security_group",
          "primary" => {
            "id" => security_group.db_security_group_name,
            "attributes" => attributes
          }
        }

        result
      end

      Terraforming::Resource.tfstate(resources)
    end
  end
end

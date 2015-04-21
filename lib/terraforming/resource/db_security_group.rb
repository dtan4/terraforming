module Terraforming::Resource
  class DBSecurityGroup
    include Terraforming::Util

    def self.tf(client = Aws::RDS::Client.new)
      self.new(client).tf
    end

    def self.tfstate(client = Aws::RDS::Client.new)
      self.new(client).tfstate
    end

    def initialize(client)
      @client = client
    end

    def tf
      apply_template(@client, "tf/db_security_group")
    end

    def tfstate
      resources = db_security_groups.inject({}) do |result, security_group|
        attributes = {
          "db_subnet_group_name" => security_group.db_security_group_name,
          "id" => security_group.db_security_group_name,
          "ingress.#" => (security_group.ec2_security_groups.length + security_group.ip_ranges.length).to_s,
          "name" => security_group.db_security_group_name,
        }
        result["aws_db_security_group.#{normalize_module_name(security_group.db_security_group_name)}"] = {
          "type" => "aws_db_security_group",
          "primary" => {
            "id" => security_group.db_security_group_name,
            "attributes" => attributes
          }
        }

        result
      end

      generate_tfstate(resources)
    end

    private

    def db_security_groups
      @client.describe_db_security_groups.db_security_groups
    end
  end
end

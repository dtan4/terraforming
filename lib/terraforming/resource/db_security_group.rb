module Terraforming::Resource
  class DBSecurityGroup
    def self.tf(data)
      ERB.new(open(Terraforming.template_path("tf/db_security_group")).read).result(binding)
    end

    def self.tfstate(data)
      tfstate_db_security_groups = data['DBSecurityGroups'].inject({}) do |result, security_group|
        attributes = {
          "db_subnet_group_name" => security_group['DBSecurityGroupName'],
          "id" => security_group['DBSecurityGroupName'],
          "ingress.#" => security_group['EC2SecurityGroups'].length.to_s,
          "name" => security_group['DBSecurityGroupName'],
        }

        result["aws_db_security_group.#{security_group['DBSecurityGroupName']}"] = {
          "type" => "aws_db_security_group",
          "primary" => {
            "id" => security_group['DBSecurityGroupName'],
            "attributes" => attributes
          }
        }
        result
      end

      JSON.pretty_generate(tfstate_db_security_groups)
    end
  end
end

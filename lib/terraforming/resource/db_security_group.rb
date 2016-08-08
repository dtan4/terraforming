module Terraforming
  module Resource
    class DBSecurityGroup
      include Terraforming::Util

      def self.tf(match, client: Aws::RDS::Client.new)
        self.new(client, match).tf
      end

      def self.tfstate(match, client: Aws::RDS::Client.new)
        self.new(client, match).tfstate
      end

      def initialize(client, match)
        @client = client
        @match_regex = Regexp.new(match) if match
      end

      def tf
        apply_template(@client, "tf/db_security_group")
      end

      def tfstate
        db_security_groups.inject({}) do |resources, security_group|
          attributes = {
            "db_subnet_group_name" => security_group.db_security_group_name,
            "id" => security_group.db_security_group_name,
            "ingress.#" => ingresses_of(security_group).length.to_s,
            "name" => security_group.db_security_group_name,
          }
          resources["aws_db_security_group.#{module_name_of(security_group)}"] = {
            "type" => "aws_db_security_group",
            "primary" => {
              "id" => security_group.db_security_group_name,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def ingresses_of(security_group)
        security_group.ec2_security_groups + security_group.ip_ranges
      end

      def db_security_groups
        @client.describe_db_security_groups.map(&:db_security_groups).flatten.select { |sg| !ingresses_of(sg).empty? }
      end

      def module_name_of(security_group)
        normalize_module_name(security_group.db_security_group_name)
      end
    end
  end
end

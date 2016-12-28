module Terraforming
  module Resource
    class IAMRole
      include Terraforming::Util

      def self.tf(client: Aws::IAM::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::IAM::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/iam_role")
      end

      def tfstate
        iam_roles.inject({}) do |resources, role|
          attributes = {
            "arn" => role.arn,
            "assume_role_policy" =>
              prettify_policy(role.assume_role_policy_document, breakline: true, unescape: true),
            "id" => role.role_name,
            "name" => role.role_name,
            "path" => role.path,
            "unique_id" => role.role_id,
          }
          resources["aws_iam_role.#{module_name_of(role)}"] = {
            "type" => "aws_iam_role",
            "primary" => {
              "id" => role.role_name,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def iam_roles
        @client.list_roles.map(&:roles).flatten
      end

      def module_name_of(role)
        normalize_module_name(role.role_name)
      end
    end
  end
end

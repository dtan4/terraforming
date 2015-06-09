module Terraforming
  module Resource
    class IAMRole
      include Terraforming::Util

      def self.tf(client = Aws::IAM::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client = Aws::IAM::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/iam_role")
      end

      def tfstate
        resources = iam_roles.inject({}) do |result, role|
          attributes = {
            "arn" => role.arn,
            "assume_role_policy" => prettify_policy(role.assume_role_policy_document, true),
            "id" => role.role_name,
            "name" => role.role_name,
            "path" => role.path,
            "unique_id" => role.role_id,
          }
          result["aws_iam_role.#{role.role_name}"] = {
            "type" => "aws_iam_role",
            "primary" => {
              "id" => role.role_name,
              "attributes" => attributes
            }
          }

          result
        end

        generate_tfstate(resources)
      end

      private

      def iam_roles
        @client.list_roles.roles
      end
    end
  end
end

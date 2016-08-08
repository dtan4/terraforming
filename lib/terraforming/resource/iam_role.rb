module Terraforming
  module Resource
    class IAMRole
      include Terraforming::Util

      def self.tf(match, client: Aws::IAM::Client.new)
        self.new(client, match).tf
      end

      def self.tfstate(match, client: Aws::IAM::Client.new)
        self.new(client, match).tfstate
      end

      def initialize(client, match)
        @client = client
        @match_regex = Regexp.new(match) if match
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
          resources["aws_iam_role.#{role.role_name}"] = {
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
    end
  end
end

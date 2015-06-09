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
        resources = iam_users.inject({}) do |result, user|
          attributes = {
            "arn"=> user.arn,
            "id" => user.user_name,
            "name" => user.user_name,
            "path" => user.path,
            "unique_id" => user.user_id,
          }
          result["aws_iam_user.#{user.user_name}"] = {
            "type" => "aws_iam_user",
            "primary" => {
              "id" => user.user_name,
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

      def prettify_policy(policy_document)
        JSON.pretty_generate(JSON.parse(CGI.unescape(policy_document))).strip
      end
    end
  end
end

module Terraforming
  module Resource
    class IAMUser
      include Terraforming::Util

      def self.tf(client: Aws::IAM::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::IAM::Client.new, tfstate_base: nil)
        self.new(client).tfstate(tfstate_base)
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/iam_user")
      end

      def tfstate(tfstate_base)
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

        generate_tfstate(resources, tfstate_base)
      end

      private

      def iam_users
        @client.list_users.users
      end
    end
  end
end

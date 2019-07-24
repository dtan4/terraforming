module Terraforming
  module Resource
    class IAMUser
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
        apply_template(@client, "tf/iam_user")
      end

      def tfstate
        iam_users.inject({}) do |resources, user|
          attributes = {
            "arn" => user.arn,
            "id" => user.user_name,
            "name" => user.user_name,
            "path" => user.path,
            "unique_id" => user.user_id,
            "force_destroy" => "false",
          }
          attributes["tags"] = user.tags.map { |tag|
            [tag.key, tag.value]
          }.to_h if user.tags.length > 0

          resources["aws_iam_user.#{module_name_of(user)}"] = {
            "type" => "aws_iam_user",
            "primary" => {
              "id" => user.user_name,
              "attributes" => attributes,
            }
          }

          resources
        end
      end

      private

      def iam_users
        @client.list_users.map(&:users).flatten.map do |user|
          user.tags = @client.list_user_tags(user_name: user.user_name).tags
          user
        end
      end

      def module_name_of(user)
        normalize_module_name(user.user_name)
      end
    end
  end
end

module Terraforming
  module Resource
    class IAMUserPolicy
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
        apply_template(@client, "tf/iam_user_policy")
      end

      def tfstate
        resources = iam_user_policies.inject({}) do |result, policy|
          attributes = {
            "id" => iam_user_policy_id_of(policy),
            "name" => policy.policy_name,
            "policy" => CGI.unescape(policy.policy_document),
            "user" => policy.user_name,
          }
          result["aws_iam_user_policy.#{policy.policy_name}"] = {
            "type" => "aws_iam_user_policy",
            "primary" => {
              "id" => iam_user_policy_id_of(policy),
              "attributes" => attributes
            }
          }

          result
        end

        generate_tfstate(resources)
      end

      private

      def iam_users
        @client.list_users.users
      end

      def iam_user_policy_id_of(policy)
        "#{policy.user_name}:#{policy.policy_name}"
      end

      def iam_user_policy_names_in(user)
        @client.list_user_policies(user_name: user.user_name).policy_names
      end

      def iam_user_policy_of(user, policy_name)
        @client.get_user_policy(user_name: user.user_name, policy_name: policy_name)
      end

      def iam_user_policies
        iam_users.map do |user|
          iam_user_policy_names_in(user).map { |policy_name| iam_user_policy_of(user, policy_name) }
        end.flatten
      end
    end
  end
end

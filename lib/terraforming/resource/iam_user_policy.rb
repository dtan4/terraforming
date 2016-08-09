module Terraforming
  module Resource
    class IAMUserPolicy
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
        apply_template(@client, "tf/iam_user_policy")
      end

      def tfstate
        iam_user_policies.inject({}) do |resources, policy|
          attributes = {
            "id" => iam_user_policy_id_of(policy),
            "name" => policy.policy_name,
            "policy" => prettify_policy(policy.policy_document, breakline: true, unescape: true),
            "user" => policy.user_name,
          }
          resources["aws_iam_user_policy.#{unique_name(policy)}"] = {
            "type" => "aws_iam_user_policy",
            "primary" => {
              "id" => iam_user_policy_id_of(policy),
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def unique_name(policy)
        "#{policy.user_name}_#{policy.policy_name}"
      end

      def iam_user_policy_id_of(policy)
        "#{policy.user_name}:#{policy.policy_name}"
      end

      def iam_users
        @client.list_users.map(&:users).flatten
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

module Terraforming
  module Resource
    class IAMUserPolicy
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
        "#{normalize_module_name(policy.user_name)}_#{normalize_module_name(policy.policy_name)}"
      end

      def iam_user_policy_id_of(policy)
        "#{policy.user_name}:#{policy.policy_name}"
      end

      def iam_users
        marker = ""
        users = []

        loop do
          resp = @client.list_users(marker: marker)
          users += resp.users
          marker = resp.marker
          break if marker.nil?
        end

        users
      end

      def iam_user_policy_names_in(user)
        marker = ""
        policies = []

        loop do
          resp = @client.list_user_policies(user_name: user.user_name, marker: marker)
          policies += resp.policy_names
          marker = resp.marker
          break if marker.nil?
        end

        policies
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

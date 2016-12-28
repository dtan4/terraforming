module Terraforming
  module Resource
    class IAMRolePolicy
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
        apply_template(@client, "tf/iam_role_policy")
      end

      def tfstate
        iam_role_policies.inject({}) do |resources, policy|
          attributes = {
            "id" => iam_role_policy_id_of(policy),
            "name" => policy.policy_name,
            "policy" => prettify_policy(policy.policy_document, breakline: true, unescape: true),
            "role" => policy.role_name,
          }
          resources["aws_iam_role_policy.#{unique_name(policy)}"] = {
            "type" => "aws_iam_role_policy",
            "primary" => {
              "id" => iam_role_policy_id_of(policy),
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def unique_name(policy)
        "#{normalize_module_name(policy.role_name)}_#{normalize_module_name(policy.policy_name)}"
      end

      def iam_role_policy_id_of(policy)
        "#{policy.role_name}:#{policy.policy_name}"
      end

      def iam_roles
        @client.list_roles.map(&:roles).flatten
      end

      def iam_role_policy_names_in(role)
        @client.list_role_policies(role_name: role.role_name).policy_names
      end

      def iam_role_policy_of(role, policy_name)
        @client.get_role_policy(role_name: role.role_name, policy_name: policy_name)
      end

      def iam_role_policies
        iam_roles.map do |role|
          iam_role_policy_names_in(role).map { |policy_name| iam_role_policy_of(role, policy_name) }
        end.flatten
      end
    end
  end
end

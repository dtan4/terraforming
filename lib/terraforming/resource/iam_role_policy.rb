module Terraforming
  module Resource
    class IAMRolePolicy
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
        apply_template(@client, "tf/iam_role_policy")
      end

      def tfstate
        resources = iam_role_policies.inject({}) do |result, policy|
          attributes = {
            "id" => iam_role_policy_id_of(policy),
            "name" => policy.policy_name,
            "policy" => prettify_policy(policy.policy_document, true),
            "role" => policy.role_name,
          }
          result["aws_iam_role_policy.#{policy.policy_name}"] = {
            "type" => "aws_iam_role_policy",
            "primary" => {
              "id" => policy.policy_name,
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

      def iam_role_policy_id_of(policy)
        "#{policy.role_name}:#{policy.policy_name}"
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

      def prettify_policy(policy_document, breakline = false)
        json = JSON.pretty_generate(JSON.parse(CGI.unescape(policy_document)))

        if breakline
          json[-1] != "\n" ? json << "\n" : json
        else
          json.strip
        end
      end
    end
  end
end

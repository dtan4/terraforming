module Terraforming
  module Resource
    class IAMPolicy
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
        apply_template(@client, "tf/iam_policy")
      end

      def tfstate
        iam_policies.inject({}) do |resources, policy|
          version = iam_policy_version_of(policy)
          attributes = {
            "id" => policy.arn,
            "name" => policy.policy_name,
            "path" => policy.path,
            "description" => iam_policy_description(policy),
            "policy" => prettify_policy(version.document, breakline: true, unescape: true),
          }
          resources["aws_iam_policy.#{module_name_of(policy)}"] = {
            "type" => "aws_iam_policy",
            "primary" => {
              "id" => policy.arn,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def iam_policies
        @client.list_policies(scope: "Local").map(&:policies).flatten
      end

      def iam_policy_description(policy)
        @client.get_policy(policy_arn: policy.arn).policy.description
      end

      def iam_policy_version_of(policy)
        @client.get_policy_version(policy_arn: policy.arn, version_id: policy.default_version_id).policy_version
      end

      def module_name_of(policy)
        normalize_module_name(policy.policy_name)
      end
    end
  end
end

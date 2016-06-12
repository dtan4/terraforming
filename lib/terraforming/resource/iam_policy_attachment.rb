module Terraforming
  module Resource
    class IAMPolicyAttachment
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
        apply_template(@client, "tf/iam_policy_attachment")
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
          resources["aws_iam_policy.#{policy.policy_name}"] = {
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

      def attachment_name_from(policy)
        "#{policy.policy_name}-policy-attachment"
      end

      def entities_for_policy(policy)
        @client.list_entities_for_policy(policy_arn: policy.arn)
      end

      def iam_policies
        @client.list_policies(scope: "Local").policies
      end

      def iam_policy_attachments
        iam_policies.map do |policy|
          {
            arn: policy.arn,
            entities: entities_for_policy(policy),
            name: attachment_name_from(policy),
          }
        end
      end
    end
  end
end

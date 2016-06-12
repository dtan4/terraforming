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
        iam_policy_attachments.inject({}) do |resources, policy_attachment|
          attributes = {
            "id" => policy_attachment[:name],
            "name" => policy_attachment[:name],
            "policy_arn" => policy_attachment[:arn],
            "groups.#" => policy_attachment[:entities].policy_groups.length.to_s,
            "users.#" => policy_attachment[:entities].policy_users.length.to_s,
            "roles.#" => policy_attachment[:entities].policy_roles.length.to_s,
          }
          resources["aws_iam_policy_attachment.#{policy_attachment[:name]}"] = {
            "type" => "aws_iam_policy_attachment",
            "primary" => {
              "id" => policy_attachment[:name],
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

module Terraforming
  module Resource
    class IAMRolePolicyAttachment
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
        apply_template(@client, "tf/iam_role_policy_attachment")
      end

      def tfstate
        iam_role_policy_attachments.inject({}) do |resources, role_policy_attachment|
          attributes = {
            "id" => role_policy_attachment[:name],
            "policy_arn" => role_policy_attachment[:policy_arn],
            "role" => role_policy_attachment[:role]
          }
          resources["aws_iam_role_policy_attachment.#{module_name_of(role_policy_attachment)}"] = {
            "type" => "aws_iam_role_policy_attachment",
            "primary" => {
              "id" => role_policy_attachment[:name],
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def attachment_name_from(role, policy)
        "#{role.role_name}-#{policy.policy_name}-attachment"
      end

      def iam_roles
        @client.list_roles.map(&:roles).flatten
      end

      def policies_attached_to(role)
        @client.list_attached_role_policies(role_name: role.role_name).attached_policies
      end

      def iam_role_policy_attachments
        iam_roles.map do |role|
          policies_attached_to(role).map do |policy|
            {
              role: role.role_name,
              policy_arn: policy.policy_arn,
              name: attachment_name_from(role, policy)
            }
          end
        end.flatten
      end

      def module_name_of(role_policy_attachment)
        normalize_module_name(role_policy_attachment[:name])
      end
    end
  end
end

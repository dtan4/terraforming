module Terraforming
  module Resource
    class IAMGroupMembership
      include Terraforming::Util

      def self.tf(client: Aws::IAM::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::IAM::Client.new, tfstate_base: nil)
        self.new(client).tfstate(tfstate_base)
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/iam_group_membership")
      end

      def tfstate(tfstate_base)
        resources = iam_groups.inject({}) do |result, group|
          membership_name = membership_name_of(group)

          attributes = {
            "group"=> group.group_name,
            "id" => membership_name,
            "name" => membership_name,
            "users.#" => group_members_of(group).length.to_s,
          }
          result["aws_iam_group_membership.#{group.group_name}"] = {
            "type" => "aws_iam_group_membership",
            "primary" => {
              "id" => membership_name,
              "attributes" => attributes
            }
          }

          result
        end

        generate_tfstate(resources, tfstate_base)
      end

      private

      def group_members_of(group)
        @client.get_group(group_name: group.group_name).users.map { |user| user.user_name }
      end

      def iam_groups
        @client.list_groups.groups
      end

      def membership_name_of(group)
        "#{group.group_name}-group-membership"
      end
    end
  end
end

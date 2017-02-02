module Terraforming
  module Resource
    class IAMGroupMembership
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
        apply_template(@client, "tf/iam_group_membership")
      end

      def tfstate
        iam_groups.inject({}) do |resources, group|
          membership_name = membership_name_of(group)

          attributes = {
            "group" => group.group_name,
            "id" => membership_name,
            "name" => membership_name,
            "users.#" => group_members_of(group).length.to_s,
          }
          resources["aws_iam_group_membership.#{module_name_of(group)}"] = {
            "type" => "aws_iam_group_membership",
            "primary" => {
              "id" => membership_name,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def group_members_of(group)
        @client.get_group(group_name: group.group_name).map(&:users).flatten.map(&:user_name)
      end

      def iam_groups
        @client.list_groups.map(&:groups).flatten
      end

      def membership_name_of(group)
        "#{group.group_name}-group-membership"
      end

      def module_name_of(group)
        normalize_module_name(group.group_name)
      end
    end
  end
end

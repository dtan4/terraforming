module Terraforming
  module Resource
    class IAMGroup
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
        apply_template(@client, "tf/iam_group")
      end

      def tfstate
        iam_groups.inject({}) do |resources, group|
          attributes = {
            "arn" => group.arn,
            "id" => group.group_name,
            "name" => group.group_name,
            "path" => group.path,
            "unique_id" => group.group_id,
          }
          resources["aws_iam_group.#{module_name_of(group)}"] = {
            "type" => "aws_iam_group",
            "primary" => {
              "id" => group.group_name,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def iam_groups
        @client.list_groups.map(&:groups).flatten
      end

      def module_name_of(group)
        normalize_module_name(group.group_name)
      end
    end
  end
end

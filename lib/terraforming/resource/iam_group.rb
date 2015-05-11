module Terraforming
  module Resource
    class IAMGroup
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
        apply_template(@client, "tf/iam_group")
      end

      def tfstate
        resources = iam_groups.inject({}) do |result, group|
          attributes = {
            "arn"=> group.arn,
            "id" => group.group_name,
            "name" => group.group_name,
            "path" => group.path,
            "unique_id" => group.group_id,
          }
          result["aws_iam_group.#{group.group_name}"] = {
            "type" => "aws_iam_group",
            "primary" => {
              "id" => group.group_name,
              "attributes" => attributes
            }
          }

          result
        end

        generate_tfstate(resources)
      end

      private

      def iam_groups
        @client.list_groups.groups
      end
    end
  end
end

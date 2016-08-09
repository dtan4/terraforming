module Terraforming
  module Resource
    class IAMGroup
      include Terraforming::Util

      def self.tf(match, client: Aws::IAM::Client.new)
        self.new(client, match).tf
      end

      def self.tfstate(match, client: Aws::IAM::Client.new)
        self.new(client, match).tfstate
      end

      def initialize(client, match)
        @client = client
        @match_regex = Regexp.new(match) if match
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
          resources["aws_iam_group.#{group.group_name}"] = {
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
    end
  end
end

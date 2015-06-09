module Terraforming
  module Resource
    class IAMInstanceProfile
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
        apply_template(@client, "tf/iam_instance_profile")
      end

      def tfstate
        resources = iam_policies.inject({}) do |result, policy|
          version = iam_policy_version_of(policy)
          attributes = {
            "id" => policy.arn,
            "name" => policy.policy_name,
            "path" => policy.path,
            "policy" => CGI.unescape(version.document),
          }
          result["aws_iam_policy.#{policy.policy_name}"] = {
            "type" => "aws_iam_policy",
            "primary" => {
              "id" => policy.arn,
              "attributes" => attributes
            }
          }

          result
        end

        generate_tfstate(resources)
      end

      private

      def iam_instance_profiles
        @client.list_instance_profiles.instance_profiles
      end
    end
  end
end

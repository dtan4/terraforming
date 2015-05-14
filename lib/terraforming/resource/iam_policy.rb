module Terraforming
  module Resource
    class IAMPolicy
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
        apply_template(@client, "tf/iam_policy")
      end

      def tfstate

      end

      private

      def iam_policies
        @client.list_policies(scope: "Local").policies
      end

      def iam_policy_version_of(policy)
        @client.get_policy_version(policy_arn: policy.arn, version_id: policy.default_version_id).policy_version
      end
    end
  end
end

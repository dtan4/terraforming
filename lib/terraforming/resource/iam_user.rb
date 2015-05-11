module Terraforming
  module Resource
    class IAMUser
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
        apply_template(@client, "tf/iam_user")
      end

      def tfstate

      end

      private

      def iam_users
        @client.list_users.users
      end
    end
  end
end

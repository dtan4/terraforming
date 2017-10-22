module Terraforming
  module Resource
    class IAMInstanceProfile
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
        apply_template(@client, "tf/iam_instance_profile")
      end

      def tfstate
        iam_instance_profiles.inject({}) do |resources, profile|
          attributes = {
            "arn" => profile.arn,
            "id" => profile.instance_profile_name,
            "name" => profile.instance_profile_name,
            "path" => profile.path,
            "role" => profile.roles[0].role_name,
            "roles.#" => profile.roles.length.to_s,
          }
          resources["aws_iam_instance_profile.#{module_name_of(profile)}"] = {
            "type" => "aws_iam_instance_profile",
            "primary" => {
              "id" => profile.instance_profile_name,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def iam_instance_profiles
        @client.list_instance_profiles.map(&:instance_profiles).flatten
      end

      def module_name_of(profile)
        normalize_module_name(profile.instance_profile_name)
      end
    end
  end
end

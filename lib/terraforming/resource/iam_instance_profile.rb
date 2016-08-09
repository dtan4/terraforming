module Terraforming
  module Resource
    class IAMInstanceProfile
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
        apply_template(@client, "tf/iam_instance_profile")
      end

      def tfstate
        iam_instance_profiles.inject({}) do |resources, profile|
          attributes = {
            "arn" => profile.arn,
            "id" => profile.instance_profile_name,
            "name" => profile.instance_profile_name,
            "path" => profile.path,
            "roles.#" => profile.roles.length.to_s,
          }
          resources["aws_iam_instance_profile.#{profile.instance_profile_name}"] = {
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
    end
  end
end

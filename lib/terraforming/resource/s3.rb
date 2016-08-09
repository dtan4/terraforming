module Terraforming
  module Resource
    class S3
      include Terraforming::Util

      def self.tf(match, client: Aws::S3::Client.new)
        self.new(client, match).tf
      end

      def self.tfstate(match, client: Aws::S3::Client.new)
        self.new(client, match).tfstate
      end

      def initialize(client, match)
        @client = client
        @match_regex = Regexp.new(match) if match
      end

      def tf
        apply_template(@client, "tf/s3")
      end

      def tfstate
        buckets.inject({}) do |resources, bucket|
          bucket_policy = bucket_policy_of(bucket)
          resources["aws_s3_bucket.#{module_name_of(bucket)}"] = {
            "type" => "aws_s3_bucket",
            "primary" => {
              "id" => bucket.name,
              "attributes" => {
                "acl" => "private",
                "bucket" => bucket.name,
                "force_destroy" => "false",
                "id" => bucket.name,
                "policy" => bucket_policy ? bucket_policy.policy.read : "",
              }
            }
          }

          resources
        end
      end

      private

      def bucket_location_of(bucket)
        @client.get_bucket_location(bucket: bucket.name).location_constraint
      end

      def bucket_policy_of(bucket)
        @client.get_bucket_policy(bucket: bucket.name)
      rescue Aws::S3::Errors::NoSuchBucketPolicy
        nil
      end

      def buckets
        @client.list_buckets.map(&:buckets).flatten.select do |resource|
          @match_regex ? module_name_of(resource) =~ @match_regex : 1
        end.select { |bucket| same_region?(bucket) }
      end

      def module_name_of(bucket)
        normalize_module_name(bucket.name)
      end

      def same_region?(bucket)
        bucket_location = bucket_location_of(bucket)
        (bucket_location == @client.config.region) || (bucket_location == "" && @client.config.region == "us-east-1")
      end
    end
  end
end

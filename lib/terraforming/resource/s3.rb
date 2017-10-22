module Terraforming
  module Resource
    class S3
      include Terraforming::Util

      def self.tf(client: Aws::S3::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::S3::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/s3")
      end

      def tfstate
        buckets.inject({}) do |resources, bucket|
          bucket_policy = bucket_policy_of(bucket)

          attributes = {
            "acl" => "private",
            "bucket" => bucket.name,
            "force_destroy" => "false",
            "id" => bucket.name,
            "policy" => bucket_policy ? bucket_policy.policy.read : ""
          }

          attributes.merge!(tags_attributes_of(bucket))

          resources["aws_s3_bucket.#{module_name_of(bucket)}"] = {
            "type" => "aws_s3_bucket",
            "primary" => {
              "id" => bucket.name,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def tags_attributes_of(bucket)
        tags = tags_of(bucket)
        if tags == nil
          return {}
        end

        attributes = { "tags.%" => tags.length.to_s }

        
        tags.each do |tag|
          attributes["tags.#{tag.key}"] = tag.value
        end

        attributes
      end

      def bucket_location_of(bucket)
        @client.get_bucket_location(bucket: bucket.name).location_constraint
      end

      def bucket_policy_of(bucket)
        @client.get_bucket_policy(bucket: bucket.name)
      rescue Aws::S3::Errors::NoSuchBucketPolicy
        nil
      end

      def buckets
        @client.list_buckets.map(&:buckets).flatten.select { |bucket| same_region?(bucket) }
      end

      def module_name_of(bucket)
        normalize_module_name(bucket.name)
      end

      def same_region?(bucket)
        bucket_location = bucket_location_of(bucket)
        (bucket_location == @client.config.region) || (bucket_location == "" && @client.config.region == "us-east-1")
      end

      def tags_of(bucket)
        begin
          return @client.get_bucket_tagging({bucket: bucket.name}).tag_set
        rescue Aws::S3::Errors::NoSuchTagSet
          return nil
        end
      end
    end
  end
end

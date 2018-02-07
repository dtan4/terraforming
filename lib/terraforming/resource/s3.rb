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
        apply_template(@client, 'tf/s3').gsub(/^[\s]*$\n/, '')
      end

      def tfstate
        buckets.inject({}) do |resources, bucket|
          bucket_policy = bucket_policy_of(bucket)
          resources["aws_s3_bucket.#{module_name_of(bucket)}"] = {
              "type" => 'aws_s3_bucket',
              "primary" => {
                  "id" => bucket.name,
                  "attributes" => {
                      "acl" => 'private',
                      "bucket" => bucket.name,
                      "force_destroy" => 'false',
                      "id" => bucket.name,
                      "policy" => bucket_policy ? bucket_policy : '',
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
        bucket.policy.policy.read
      rescue Aws::S3::Errors::NoSuchBucketPolicy
        nil
      end

      def buckets
        return @buckets unless @buckets.nil?
        @buckets = []
        @client.list_buckets.map(&:buckets).flatten.each do |bucket|
          @buckets << Aws::S3::Bucket.new(bucket.name, client: @client) if same_region?(bucket)
        end
        @buckets
      end

      def region(bucket)
        bucket_location_of(bucket)
      end

      def module_name_of(bucket)
        normalize_module_name(bucket.name)
      end

      def tagging?(bucket)
        return false if bucket.tagging.tag_set.nil?
        true
      rescue Aws::S3::Errors::NoSuchTagSet
        false
      end

      def cors?(bucket)
        return false if bucket.cors.cors_rules.nil?
        true
      rescue Aws::S3::Errors::NoSuchCORSConfiguration
        false
      end

      def lifecycle?(bucket)
        return false if bucket.lifecycle_configuration.rules.nil?
        true
      rescue Aws::S3::Errors::NoSuchLifecycleConfiguration
        false
      end

      def website_configuation?(bucket)
        return false if bucket.website.index_document.nil?
        true
      rescue Aws::S3::Errors::NoSuchWebsiteConfiguration
        false
      end

      def prettify_website_routing_rules(bucket)
        prettify_policy(bucket.website.routing_rules.map { |t| t.to_h.to_json }.to_json.gsub('"{', '{').gsub('\"', '"').gsub('}"', '}'))
      end

      def same_region?(bucket)
        bucket_location = bucket_location_of(bucket)
        (bucket_location == @client.config.region) || (bucket_location == "" && @client.config.region == "us-east-1")
      end
    end
  end
end

module Terraforming
  module Resource
    class CloudWatchLogGroup
      include Terraforming::Util

      def self.tf(client: Aws::CloudWatchLogs::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::CloudWatchLogs::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/cloud_watch_log_group")
      end

      def tfstate
        log_groups.inject({}) do |resources, log_group|
          attributes = {
            "arn"                 => log_group["arn"].to_s,
            "creation_time"       => log_group["creation_time"].to_i,
            "kms_key_id"          => log_group["kms_key_id"].to_s,
            "log_group_name"      => log_group["log_group_name"].to_s,
            "metric_filter_count" => log_group["metric_filter_count"].to_i,
            "retention_in_days"   => log_group["retention_in_days"].to_i,
            "stored_bytes"        => log_group["stored_bytes"].to_i
          }

          resources["aws_cloudwatch_log_group.#{module_name_of(log_group)}"] = {
            "type" => "aws_cloudwatch_log_group",
            "primary" => {
              "id" => log_group.log_group_name,
              "attributes" => attributes
            }
          }
        end
      end

      private

      def log_groups
        @client.describe_log_groups.map(&:log_groups).flatten
      end

      def module_name_of(log_group)
        normalize_module_name(log_group.log_group_name)
      end

      def tag_attributes_of(log_group)
        tags = tags_of(log_group)
        attributes = { "tags.%" => tags.length.to_s }
        tags.each do |tag|
          attributes["tags.#{tag.key}"] = tag.value
        end
        attributes
      end

      def tags_of(log_group)
        @client.list_tags_log_group({
          log_group_name: "#{log_group.log_group_name}"
        })
      end      

    end
  end
end

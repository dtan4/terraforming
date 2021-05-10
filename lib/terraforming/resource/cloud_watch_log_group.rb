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
          resources["aws_cloudwatch_log_group.#{module_name_of(log_group)}"] = {
            "type" => "aws_cloudwatch_log_group",
            "primary" => {
              "id" => log_group.name,
              "attributes" => log_group_attributes(log_group)
            }
          }
          resources
        end
      end

      private

      def log_group_attributes(log_group)
        attributes = {
          "id" => log_group.name.to_s,
          "name" => log_group.name.to_s,
          "name_prefix" => sanitize(log_group.name_prefix),
          "retention_in_days" => log_group.retention_in_days,
          "tags" => log_group.tags,
          "arn" => log_group.arn
        }
        add_checksummed_attributes(attributes, log_group)
      end

      def log_groups
        @client.describe_log_groups.map(&:log_groups).flatten
      end

      def module_name_of(log_group)
        normalize_module_name(log_group.name)
      end

      def sanitize(argument)
        argument.nil? ? "" : argument
      end

      def add_checksummed_attributes(attributes, log_group)
        %w(insufficient_data_actions log_group_actions ok_actions dimensions).each do |action|
          attribute = log_group.send(action.to_sym)
          attributes["#{action}.#"] = attribute.size.to_s
          attribute.each do |attr|
            if attr.is_a? String
              checksum = Zlib.crc32(attr)
              value = attr
            else
              checksum = attr.name
              value = attr.value
            end
            attributes["#{action}.#{checksum}"] = value
          end
        end

        attributes
      end
    end
  end
end

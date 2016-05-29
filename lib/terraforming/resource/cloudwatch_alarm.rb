module Terraforming
  module Resource
    class CloudWatchAlarm
      include Terraforming::Util

      def self.tf(client: Aws::CloudWatch::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::CloudWatch::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/cloudwatch_alarm")
      end

      def tfstate
        alarms.inject({}) do |resources, alarm|
          attributes = {
            "alarm_name" => alarm.alarm_name,
            "comparison_operator" => alarm.comparison_operator,
            "evaluation_periods" => alarm.evaluation_periods.to_s,
            "metric_name" => alarm.metric_name,
            "namespace" => alarm.namespace,
            "period" => alarm.period.to_s,
            "statistic" => alarm.statistic,
            "threshold" => alarm.threshold.to_s,
            "unit" => alarm.unit
          }
          attributes.delete_if{|k, v| v.nil?}
          attributes["alarm_description"] = alarm.alarm_description.to_s unless alarm.alarm_description.to_s.empty?

          attributes["insufficient_data_actions.#"] = alarm.insufficient_data_actions.size.to_s
          alarm.insufficient_data_actions.each do |a|
            attributes["insufficient_data_actions.#{Zlib.crc32(a)}"] = a
          end

          attributes["alarm_actions.#"] = alarm.alarm_actions.size.to_s
          alarm.alarm_actions.each do |a|
            attributes["alarm_actions.#{Zlib.crc32(a)}"] = a
          end

          attributes["ok_actions.#"] = alarm.ok_actions.size.to_s
          alarm.ok_actions.each do |a|
            attributes["ok_actions.#{Zlib.crc32(a)}"] = a
          end

          attributes["actions_enabled"] = alarm.actions_enabled.to_s

          attributes["dimensions.#"] = alarm.dimensions.size.to_s

          alarm.dimensions.each do |d|
            attributes["dimensions.#{d.name}"] = d.value.to_s
          end

          resources["aws_cloudwatch_metric_alarm.#{normalize_module_name(alarm.alarm_name)}"] = {
            "type" => "aws_cloudwatch_metric_alarm",
            "primary" => {
              "id" => alarm.alarm_name,
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def alarms
        @client.describe_alarms.metric_alarms
      end
    end
  end
end

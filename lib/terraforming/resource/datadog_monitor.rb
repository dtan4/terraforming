module Terraforming
  module Resource
    class DatadogMonitor
      include Terraforming::Util

      def self.api_key
        raise "Missing Datadog API key. Set it env DATADOG_API_KEY" if ENV["DATADOG_API_KEY"].nil?
        ENV["DATADOG_API_KEY"]
      end

      def self.app_key
        raise "Missing Datadog APP key. Set it env DATADOG_APP_KEY" if ENV["DATADOG_APP_KEY"].nil?
        ENV["DATADOG_APP_KEY"]
      end

      def self.tf(client: Dogapi::Client.new(self.api_key, self.app_key))
        self.new(client).tf
      end

      def self.tfstate(client: Dogapi::Client.new(self.api_key, self.app_key))
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/datadog_monitor")
      end

      def tfstate
        monitors.inject({}) do |resources, monitor|
          resources["datadog_monitor.#{module_name_of(monitor)}"] = {
            "type" => "datadog_monitor",
            "depends_on" => [],
            "primary" => {
              "id" => monitor["id"].to_s,
              "attributes" => monitor_attributes(monitor),
              "meta" => {},
              "tainted" => false
            },
            "deposed" => [],
            "provider" => ""
          }
          resources
        end
      end

      private

      def monitors
        response = check_response(@client.get_all_monitors)

        # Fix missing thresholds
        response.each do |monitor|
          if monitor["options"]["thresholds"].nil?
            critical = monitor["query"].split.last
            monitor["options"]["thresholds"] = { "critical" => critical }
          else
            monitor["options"]["thresholds"].each { |k, v| monitor["options"]["thresholds"][k] = v.round }
          end
        end

        response
      end
      
      def check_response(response)
        case response[0]
        when "401"
          raise "Access Unauthorized, Datadog responded with a 401"
        when "403"
          raise "Access Forbidden, Datadog responded with a 403"
        when "500"
          raise "Server Error, Datadog responded with a 500"
        end

        response[1]
      end

      def module_name_of(monitor)
        normalize_module_name(monitor["name"])
      end

      def monitor_attributes(monitor)
        attributes = {
          "id" => monitor["id"],
          "name" => monitor["name"],
          "type" => monitor["type"],
          "message" => monitor["message"],
          "escalation_message" => monitor["escalation_message"],
          "query" => monitor["query"],
          "notify_no_data" => monitor["options"]["notify_no_data"],
          "no_data_timeframe" => monitor["options"]["no_data_timeframe"],
          "renotify_interval" => monitor["options"]["renotify_interval"],
          "notify_audit" => monitor["options"]["notify_audit"],
          "timeout_h" => monitor["options"]["timeout_h"],
          "include_tags" => monitor["options"]["include_tags"],
          "require_full_window" => monitor["options"]["name"],
          "locked" => monitor["options"]["locked"]
        }
        %w(silenced thresholds).each do |argument|
            option = monitor["options"][argument]
            next if option.nil?
            attributes["#{argument}.%"] = option.length
            option.each { |k, v| attributes["#{argument}.#{k}"] = v }
        end
        attributes["tags.%"] = monitor["tags"].length
        monitor["tags"].each { |tag| attributes["tags.#{tag.split(":")[0]}"] = tag.split(":")[0] }

        sanitize_monitor(attributes)
      end

      def sanitize_monitor(attributes)
        attributes = Hash[ attributes.sort_by { |k, v| k }]

        attributes.each do |key, value|
          attributes[key] = value.to_s
        end
        %w(include_tags locked require_full_window).each do |attribute|
          attributes[attribute] = "false" if attributes[attribute] == ""
        end

        attributes
      end
    end
  end
end

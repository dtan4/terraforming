require "spec_helper"

module Terraforming
  module Resource
    describe DatadogMonitor do
      let(:client) { instance_double(Dogapi::Client).as_null_object }

      let(:monitors) do
        [ "200",
          [
            {
              "tags"=>[],
              "deleted"=>nil,
              "query"=>"avg(last_1h):avg:aws.xxxx > 15000",
              "message"=>"@slack-team-xxxx",
              "matching_downtimes"=>[],
              "id"=>521075,
              "multi"=>false,
              "name"=>"terraform alarm 1",
              "created"=>"2016-03-18T14:19:19.948460+00:00",
              "created_at"=>1458310759000,
              "creator"=> {
                "id"=>177888,
                "handle"=>"j@example.com",
                "name"=>"J Doe",
                "email"=>"j@example.com"
              },
              "org_id"=>32497,
              "modified"=>"2016-03-22T13:23:52.824631+00:00",
              "overall_state"=>"OK",
              "type"=>"metric alert",
              "options"=>{
                "notify_audit"=>false,
                "timeout_h"=>0,
                "silenced"=>{},
                "thresholds"=>{
                  "critical"=>15000.0,
                  "warning"=>12500.0
                },
                "notify_no_data"=>false,
                "renotify_interval"=>0,
                "no_data_timeframe"=>120
              }
            },
            {
              "tags"=>[],
              "deleted"=>nil,
              "query"=>"avg(last_1h):avg:aws.yyyy > 1000",
              "message"=>"@slack-team-yyyy",
              "matching_downtimes"=>[],
              "id"=>521076,
              "multi"=>false,
              "name"=>"terraform alarm 2",
              "created"=>"2016-03-18T14:19:19.948460+00:00",
              "created_at"=>1458310759000,
              "creator"=> {
                "id"=>177888,
                "handle"=>"j@example.com",
                "name"=>"J Doe",
                "email"=>"j@example.com"
              },
              "org_id"=>32497,
              "modified"=>"2016-03-22T13:23:52.824631+00:00",
              "overall_state"=>"OK",
              "type"=>"metric alert",
              "options"=>{
                "notify_audit"=>false,
                "timeout_h"=>0,
                "silenced"=>{},
                "thresholds"=>{
                  "critical"=>1000.0
                },
                "notify_no_data"=>false,
                "renotify_interval"=>0,
                "no_data_timeframe"=>120
              }
            }
          ]
        ]
      end

      before do
        allow(client).to receive(:get_all_monitors).and_return(monitors)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "datadog_monitor" "terraform-alarm-1" {
    name    = "terraform alarm 1"
    type    = "metric alert"
    query   = "avg(last_1h):avg:aws.xxxx > 15000"
    message = "@slack-team-xxxx"

    thresholds {
        critical = 15000
        warning = 12500
    }

    notify_no_data = false
    renotify_interval = 0
    notify_audit = false
    timeout_h = 0
}

resource "datadog_monitor" "terraform-alarm-2" {
    name    = "terraform alarm 2"
    type    = "metric alert"
    query   = "avg(last_1h):avg:aws.yyyy > 1000"
    message = "@slack-team-yyyy"

    thresholds {
        critical = 1000
    }

    notify_no_data = false
    renotify_interval = 0
    notify_audit = false
    timeout_h = 0
}

          EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "datadog_monitor.terraform-alarm-1" => {
              "type"=> "datadog_monitor",
              "depends_on" => [],
              "primary" => {
                  "id" => "521075",
                  "attributes" => {
                      "escalation_message" => "",
                      "id" => "521075",
                      "include_tags" => "false",
                      "locked" => "false",
                      "message" => "@slack-team-xxxx",
                      "name" => "terraform alarm 1",
                      "no_data_timeframe" => "120",
                      "notify_audit" => "false",
                      "notify_no_data" => "false",
                      "query" => "avg(last_1h):avg:aws.xxxx \u003e 15000",
                      "renotify_interval" => "0",
                      "require_full_window" => "false",
                      "silenced.%" => "0",
                      "tags.%" => "0",
                      "thresholds.%" => "2",
                      "thresholds.critical" => "15000",
                      "thresholds.warning" => "12500",
                      "timeout_h" => "0",
                      "type" => "metric alert"
                  },
                  "meta" => {},
                  "tainted" => false
              },
              "deposed" => [],
              "provider" => ""
            },
            "datadog_monitor.terraform-alarm-2" => {
              "type" => "datadog_monitor",
              "depends_on" => [],
              "primary" => {
                  "id" => "521076",
                  "attributes" => {
                      "escalation_message" => "",
                      "id" => "521076",
                      "include_tags" => "false",
                      "locked" => "false",
                      "message" => "@slack-team-yyyy",
                      "name" => "terraform alarm 2",
                      "no_data_timeframe" => "120",
                      "notify_audit" => "false",
                      "notify_no_data" => "false",
                      "query" => "avg(last_1h):avg:aws.yyyy \u003e 1000",
                      "renotify_interval" => "0",
                      "require_full_window" => "false",
                      "silenced.%" => "0",
                      "tags.%" => "0",
                      "thresholds.%" => "1",
                      "thresholds.critical" => "1000",
                      "timeout_h" => "0",
                      "type" => "metric alert"
                  },
                  "meta" => {},
                  "tainted" => false
              },
              "deposed" => [],
              "provider" => ""
            }           
          })
        end
      end
    end
  end
end

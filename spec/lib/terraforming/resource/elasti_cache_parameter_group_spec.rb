require "spec_helper"

module Terraforming
  module Resource
    describe ElastiCacheParameterGroup do
      let(:client) do
        Aws::ElastiCache::Client.new(stub_responses: true)
      end

      let(:cache_parameter_groups) do
        [
          {
            cache_parameter_group_name: "default.memcached1.4",
            cache_parameter_group_family: "memcached1.4",
            description: "Default parameter group for memcached1.4"
          },
          {
            cache_parameter_group_name: "default.redis2.6",
            cache_parameter_group_family: "redis2.6",
            description: "Default parameter group for redis2.6"
          }
        ]
      end

      let(:memcached_parameters) do
        [
          {
            parameter_name: "backlog_queue_limit",
            parameter_value: "1024",
            description: "The backlog queue limit",
            source: "system",
            data_type: "integer",
            allowed_values: "1-10000",
            is_modifiable: false,
            minimum_engine_version: "1.4.5",
            change_type: "requires-reboot"
          },
          {
            parameter_name: "cas_disabled",
            parameter_value: "0",
            description: "If supplied, CAS operations will be disabled, and items stored will consume 8 bytes less than with CAS enabled.",
            source: "system",
            data_type: "boolean",
            allowed_values: "0,1",
            is_modifiable: true,
            minimum_engine_version: "1.4.5",
            change_type: "requires-reboot"
          }
        ]
      end

      let(:redis_parameters) do
        [
          {
            parameter_name: "activerehashing",
            parameter_value: "yes",
            description: "Apply rehashing or not.",
            source: "system",
            data_type: "string",
            allowed_values: "yes,no",
            is_modifiable: true,
            minimum_engine_version: "2.6.13",
            change_type: "requires-reboot"
          },
          {
            parameter_name: "appendfsync",
            parameter_value: "everysec",
            description: "fsync policy for AOF persistence",
            source: "system",
            data_type: "string",
            allowed_values: "always,everysec,no",
            is_modifiable: true,
            minimum_engine_version: "2.6.13",
            change_type: "immediate"
          }
        ]
      end

      before do
        client.stub_responses(:describe_cache_parameter_groups, cache_parameter_groups: cache_parameter_groups)
        client.stub_responses(:describe_cache_parameters, [{ parameters: memcached_parameters }, { parameters: redis_parameters }])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_elasticache_parameter_group" "default-memcached1-4" {
    name        = "default.memcached1.4"
    family      = "memcached1.4"
    description = "Default parameter group for memcached1.4"

    parameter {
        name  = "backlog_queue_limit"
        value = "1024"
    }

    parameter {
        name  = "cas_disabled"
        value = "0"
    }

}

resource "aws_elasticache_parameter_group" "default-redis2-6" {
    name        = "default.redis2.6"
    family      = "redis2.6"
    description = "Default parameter group for redis2.6"

    parameter {
        name  = "activerehashing"
        value = "yes"
    }

    parameter {
        name  = "appendfsync"
        value = "everysec"
    }

}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_elasticache_parameter_group.default-memcached1-4" => {
              "type" => "aws_elasticache_parameter_group",
              "primary" => {
                "id" => "default.memcached1.4",
                "attributes" => {
                  "description" => "Default parameter group for memcached1.4",
                  "family" => "memcached1.4",
                  "id" => "default.memcached1.4",
                  "name" => "default.memcached1.4",
                  "parameter.#" => "2",
                }
              }
            },
            "aws_elasticache_parameter_group.default-redis2-6" => {
              "type" => "aws_elasticache_parameter_group",
              "primary" => {
                "id" => "default.redis2.6",
                "attributes" => {
                  "description" => "Default parameter group for redis2.6",
                  "family" => "redis2.6",
                  "id" => "default.redis2.6",
                  "name" => "default.redis2.6",
                  "parameter.#" => "2",
                }
              }
            }
          })
        end
      end
    end
  end
end

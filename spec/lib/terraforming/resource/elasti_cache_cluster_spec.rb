require "spec_helper"

module Terraforming
  module Resource
    describe ElastiCacheCluster do
      let(:client) do
        Aws::ElastiCache::Client.new(stub_responses: true)
      end

      let(:cache_clusters) do
        [
          {
            cache_cluster_id: "hoge",
            configuration_endpoint: {
              address: "hoge.abc123.cfg.apne1.cache.amazonaws.com",
              port: 11211
            },
            client_download_landing_page: "https://console.aws.amazon.com/elasticache/home#client-download:",
            cache_node_type: "cache.m1.small",
            engine: "memcached",
            engine_version: "1.4.5",
            cache_cluster_status: "available",
            num_cache_nodes: 1,
            preferred_availability_zone: "ap-northeast-1b",
            cache_cluster_create_time: Time.parse("2014-06-25 00:00:00 UTC"),
            preferred_maintenance_window: "fri:20:00-fri:21:00",
            pending_modified_values: {},
            cache_security_groups: [],
            cache_parameter_group: {
              cache_parameter_group_name: "default.memcached1.4",
              parameter_apply_status: "in-sync",
              cache_node_ids_to_reboot: []
            },
            cache_subnet_group_name: "subnet-hoge",
            cache_nodes: [
              {
                cache_node_id: "0001",
                cache_node_status: "available",
                cache_node_create_time: Time.parse("2014-08-28 12:51:55 UTC"),
                endpoint: {
                  address: "hoge.abc123.0001.apne1.cache.amazonaws.com",
                  port: 11211
                },
                parameter_group_status: "in-sync",
                customer_availability_zone: "ap-northeast-1b"
              }
            ],
            auto_minor_version_upgrade: false,
            security_groups: [
              { security_group_id: "sg-abcd1234", status: "active" }
            ]
          },
          {
            cache_cluster_id: "fuga",
            client_download_landing_page: "https://console.aws.amazon.com/elasticache/home#client-download:",
            cache_node_type: "cache.t2.micro",
            engine: "redis",
            engine_version: "2.8.6",
            cache_cluster_status: "available",
            num_cache_nodes: 1,
            preferred_availability_zone: "ap-northeast-1b",
            cache_cluster_create_time: Time.parse("2014-06-25 12:34:56 UTC"),
            preferred_maintenance_window: "fri:20:00-fri:21:00",
            pending_modified_values: {},
            cache_security_groups: [
              { cache_security_group_name: "sg-hoge", status: "active" },
            ],
            cache_parameter_group: {
              cache_parameter_group_name: "default.redis2.8",
              parameter_apply_status: "in-sync",
              cache_node_ids_to_reboot: []
            },
            cache_subnet_group_name: "subnet-fuga",
            cache_nodes: [
              {
                cache_node_id: "0001",
                cache_node_status: "available",
                cache_node_create_time: Time.parse("2014-08-28 12:51:55 UTC"),
                endpoint: {
                  address: "fuga.def456.0001.apne1.cache.amazonaws.com",
                  port: 6379
                },
                parameter_group_status: "in-sync",
                customer_availability_zone: "ap-northeast-1b"
              }
            ],
            auto_minor_version_upgrade: false,
            security_groups: [],
          },
        ]
      end

      before do
        client.stub_responses(:describe_cache_clusters, cache_clusters: cache_clusters)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_elasticache_cluster" "hoge" {
    cluster_id           = "hoge"
    engine               = "memcached"
    engine_version       = "1.4.5"
    node_type            = "cache.m1.small"
    num_cache_nodes      = 1
    parameter_group_name = "default.memcached1.4"
    port                 = 11211
    subnet_group_name    = "subnet-hoge"
    security_group_ids   = ["sg-abcd1234"]
}

resource "aws_elasticache_cluster" "fuga" {
    cluster_id           = "fuga"
    engine               = "redis"
    engine_version       = "2.8.6"
    node_type            = "cache.t2.micro"
    num_cache_nodes      = 1
    parameter_group_name = "default.redis2.8"
    port                 = 6379
    security_group_names = ["sg-hoge"]
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_elasticache_cluster.hoge" => {
              "type" => "aws_elasticache_cluster",
              "primary" => {
                "id" => "hoge",
                "attributes" => {
                  "cache_nodes.#" => "1",
                  "cluster_id" => "hoge",
                  "engine" => "memcached",
                  "engine_version" => "1.4.5",
                  "id" => "hoge",
                  "node_type" => "cache.m1.small",
                  "num_cache_nodes" => "1",
                  "parameter_group_name" => "default.memcached1.4",
                  "security_group_ids.#" => "1",
                  "security_group_names.#" => "0",
                  "subnet_group_name" => "subnet-hoge",
                  "tags.#" => "0",
                  "port" => "11211"
                }
              }
            },
            "aws_elasticache_cluster.fuga" => {
              "type" => "aws_elasticache_cluster",
              "primary" => {
                "id" => "fuga",
                "attributes" => {
                  "cache_nodes.#" => "1",
                  "cluster_id" => "fuga",
                  "engine" => "redis",
                  "engine_version" => "2.8.6",
                  "id" => "fuga",
                  "node_type" => "cache.t2.micro",
                  "num_cache_nodes" => "1",
                  "parameter_group_name" => "default.redis2.8",
                  "security_group_ids.#" => "0",
                  "security_group_names.#" => "1",
                  "subnet_group_name" => "subnet-fuga",
                  "tags.#" => "0",
                  "port" => "6379"
                }
              }
            }
          })
        end
      end
    end
  end
end

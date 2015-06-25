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
            auto_minor_version_upgrade: false,
            security_groups: [
              { security_group_id: "sg-abcd1234", status: "active" }
            ]
          },
          {
            cache_cluster_id: "fuga",
            configuration_endpoint: {
              address: "fuga.def456.cfg.apne1.cache.amazonaws.com",
              port: 11211
            },
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
    port                 = 11211
    security_group_names = ["sg-hoge"]
}

        EOS
        end
      end

      describe ".tfstate" do
        context "without existing tfstate" do
          it "should generate tfstate" do
            expect(described_class.tfstate(client: client)).to eq JSON.pretty_generate({
              "version" => 1,
              "serial" => 1,
              "modules" => [
                {
                  "path" => [
                    "root"
                  ],
                  "outputs" => {},
                  "resources" => {
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
                          "port" => "11211",
                          "security_group_ids.#" => "1",
                          "security_group_names.#" => "0",
                          "subnet_group_name" => "subnet-hoge",
                          "tags.#" => "0",
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
                          "port" => "11211",
                          "security_group_ids.#" => "0",
                          "security_group_names.#" => "1",
                          "subnet_group_name" => "subnet-fuga",
                          "tags.#" => "0",
                        }
                      }
                    },
                  }
                }
              ]
            })
          end
        end

        context "with existing tfstate" do
          it "should generate tfstate and merge it to existing tfstate" do
            expect(described_class.tfstate(client: client, tfstate_base: tfstate_fixture)).to eq JSON.pretty_generate({
              "version" => 1,
              "serial" => 89,
              "remote" => {
                "type" => "s3",
                "config" => { "bucket" => "terraforming-tfstate", "key" => "tf" }
              },
              "modules" => [
                {
                  "path" => ["root"],
                  "outputs" => {},
                  "resources" => {
                    "aws_elb.hogehoge" => {
                      "type" => "aws_elb",
                      "primary" => {
                        "id" => "hogehoge",
                        "attributes" => {
                          "availability_zones.#" => "2",
                          "connection_draining" => "true",
                          "connection_draining_timeout" => "300",
                          "cross_zone_load_balancing" => "true",
                          "dns_name" => "hoge-12345678.ap-northeast-1.elb.amazonaws.com",
                          "health_check.#" => "1",
                          "id" => "hogehoge",
                          "idle_timeout" => "60",
                          "instances.#" => "1",
                          "listener.#" => "1",
                          "name" => "hoge",
                          "security_groups.#" => "2",
                          "source_security_group" => "default",
                          "subnets.#" => "2"
                        }
                      }
                    },
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
                          "port" => "11211",
                          "security_group_ids.#" => "1",
                          "security_group_names.#" => "0",
                          "subnet_group_name" => "subnet-hoge",
                          "tags.#" => "0",
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
                          "port" => "11211",
                          "security_group_ids.#" => "0",
                          "security_group_names.#" => "1",
                          "subnet_group_name" => "subnet-fuga",
                          "tags.#" => "0",
                        }
                      }
                    },
                  }
                }
              ]
            })
          end
        end
      end
    end
  end
end

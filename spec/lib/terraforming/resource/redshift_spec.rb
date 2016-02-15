require "spec_helper"

module Terraforming
  module Resource
    describe Redshift do
      let(:client) do
        Aws::Redshift::Client.new(stub_responses: true)
      end

      let(:clusters) do
        [
          {
            cluster_identifier: "test",
            node_type: "dc1.large",
            cluster_status: "available",
            modify_status: nil,
            master_username: "testuser",
            db_name: "testdb",
            endpoint: {
              address: "test.xxxxxxxxxxxx.ap-northeast-1.redshift.amazonaws.com",
              port: 5439
            },
            cluster_create_time: Time.parse("2016-01-01T00:00:00Z"),
            automated_snapshot_retention_period: 1,
            cluster_security_groups: [],
            vpc_security_groups: [],
            cluster_parameter_groups: [
              {
                parameter_group_name: "default.redshift-1.0",
                parameter_apply_status: "in-sync",
                cluster_parameter_status_list: []
              }
            ],
            cluster_subnet_group_name: "test",
            vpc_id: "vpc-xxxxxxxx",
            availability_zone: "ap-northeast-1c",
            preferred_maintenance_window: "fri:15:00-fri:15:30",
            pending_modified_values: {
              master_user_password: nil,
              node_type: nil,
              number_of_nodes: nil,
              cluster_type: nil,
              cluster_version: nil,
              automated_snapshot_retention_period: nil,
              cluster_identifier: nil
            },
            cluster_version: "1.0",
            allow_version_upgrade: true,
            number_of_nodes: 2,
            publicly_accessible: true,
            encrypted: true,
            restore_status: {
              status: "completed",
              current_restore_rate_in_mega_bytes_per_second: 20.000,
              snapshot_size_in_mega_bytes: 10000,
              progress_in_mega_bytes: 10000,
              elapsed_time_in_seconds: 500,
              estimated_time_to_completion_in_seconds: 0
            },
            hsm_status: nil,
            cluster_snapshot_copy_status: nil,
            cluster_public_key: "ssh-rsa AAAAB3NzaC1yc2E... Amazon-Redshift\n",
            cluster_nodes: [
              {
                node_role: "LEADER",
                private_ip_address: "10.0.0.1",
                public_ip_address: "192.0.2.1"
              },
              {
                node_role: "COMPUTE-0",
                private_ip_address: "10.0.0.2",
                public_ip_address: "192.0.2.2"
              },
              {
                node_role: "COMPUTE-1",
                private_ip_address: "10.0.0.3",
                public_ip_address: "192.0.2.3"
              }
            ],
            elastic_ip_status: nil,
            cluster_revision_number: "1026",
            tags: [],
            kms_key_id: nil
          }
        ]
      end

      before do
        client.stub_responses(:describe_clusters, clusters: clusters)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_redshift_cluster" "test" {
    cluster_identifier                  = "test"
    database_name                       = "testdb"
    cluster_type                        = "multi-node"
    node_type                           = "dc1.large"
    master_password                     = "xxxxxxxx"
    master_username                     = "testuser"
    availability_zone                   = "ap-northeast-1c"
    preferred_maintenance_window        = "fri:15:00-fri:15:30"
    cluster_parameter_group_name        = "default.redshift-1.0"
    automated_snapshot_retention_period = "1"
    port                                = "5439"
    cluster_version                     = "1.0"
    allow_version_upgrade               = "true"
    number_of_nodes                     = "2"
    publicly_accessible                 = "true"
    encrypted                           = "true"
    skip_final_snapshot                 = "true"
}
        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_redshift_cluster.test" => {
              "type" => "aws_redshift_cluster",
              "primary" => {
                "id" => "test",
                "attributes" => {
                  "cluster_identifier"                  => "test",
                  "database_name"                       => "testdb",
                  "cluster_type"                        => "multi-node",
                  "node_type"                           => "dc1.large",
                  "master_password"                     => "xxxxxxxx",
                  "master_username"                     => "testuser",
                  "availability_zone"                   => "ap-northeast-1c",
                  "preferred_maintenance_window"        => "fri:15:00-fri:15:30",
                  "cluster_parameter_group_name"        => "default.redshift-1.0",
                  "automated_snapshot_retention_period" => "1",
                  "port"                                => "5439",
                  "cluster_version"                     => "1.0",
                  "allow_version_upgrade"               => "true",
                  "number_of_nodes"                     => "2",
                  "publicly_accessible"                 => "true",
                  "encrypted"                           => "true",
                  "skip_final_snapshot"                 => "true",
                }
              }
            },
          })
        end
      end
    end
  end
end

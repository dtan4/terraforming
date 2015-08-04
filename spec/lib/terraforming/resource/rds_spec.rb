require "spec_helper"

module Terraforming
  module Resource
    describe RDS do
      let(:client) do
        Aws::RDS::Client.new(stub_responses: true)
      end

      let(:db_instances) do
        [
          {
            publicly_accessible: false,
            master_username: "user",
            license_model: "postgresql-license",
            vpc_security_groups: [
              {
                status: "active",
                vpc_security_group_id: "sg-1234abcd"
              }
            ],
            instance_create_time: Time.parse("2014-01-01T00:00:00.000Z"),
            option_group_memberships: [
              {
                status: "in-sync",
                option_group_name: "default:postgres-9-4"
              }
            ],
            pending_modified_values: {
            },
            engine: "postgres",
            multi_az: false,
            latest_restorable_time: Time.parse("2015-01-01T00:00:00Z"),
            db_security_groups: [

            ],
            db_parameter_groups: [
              {
                db_parameter_group_name: "default.postgres9.4",
                parameter_apply_status: "in-sync"
              }
            ],
            auto_minor_version_upgrade: false,
            preferred_backup_window: "23:00-23:30",
            db_subnet_group: {
              subnets: [
                {
                  subnet_status: "Active",
                  subnet_identifier: "subnet-1234abcd",
                  subnet_availability_zone: {
                    name: "ap-northeast-1b"
                  }
                },
                {
                  subnet_status: "Active",
                  subnet_identifier: "subnet-5678efgh",
                  subnet_availability_zone: {
                    name: "ap-northeast-1c"
                  }
                }
              ],
              db_subnet_group_name: "hogedb-subnet",
              vpc_id: "vpc-1234abcd",
              db_subnet_group_description: "hogehoge",
              subnet_group_status: "Complete"
            },
            read_replica_db_instance_identifiers: [

            ],
            allocated_storage: 10,
            backup_retention_period: 1,
            db_name: "hogedb",
            preferred_maintenance_window: "mon:00:00-mon:00:30",
            endpoint: {
              port: 5432,
              address: "hogefuga.ap-northeast-1.rds.amazonaws.com"
            },
            db_instance_status: "available",
            engine_version: "9.4.1",
            availability_zone: "ap-northeast-1b",
            storage_type: "standard",
            dbi_resource_id: "db-1234ABCD5678EFGH1234ABCD56",
            storage_encrypted: false,
            db_instance_class: "db.m3.large",
            db_instance_identifier: "hogedb"
          }
        ]
      end

      before do
        client.stub_responses(:describe_db_instances, db_instances: db_instances)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_db_instance" "hogedb" {
    identifier                = "hogedb"
    allocated_storage         = 10
    storage_type              = "standard"
    engine                    = "postgres"
    engine_version            = "9.4.1"
    instance_class            = "db.m3.large"
    name                      = "hogedb"
    username                  = "user"
    password                  = "xxxxxxxx"
    port                      = 5432
    publicly_accessible       = false
    availability_zone         = "ap-northeast-1b"
    security_group_names      = []
    vpc_security_group_ids    = ["sg-1234abcd"]
    db_subnet_group_name      = "hogedb-subnet"
    parameter_group_name      = "default.postgres9.4"
    multi_az                  = false
    backup_retention_period   = 1
    backup_window             = "23:00-23:30"
    maintenance_window        = "mon:00:00-mon:00:30"
    final_snapshot_identifier = "hogedb-final"
}
        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_db_instance.hogedb" => {
              "type" => "aws_db_instance",
              "primary" => {
                "id" => "hogedb",
                "attributes" => {
                  "address" => "hogefuga.ap-northeast-1.rds.amazonaws.com",
                  "allocated_storage" => "10",
                  "availability_zone" => "ap-northeast-1b",
                  "backup_retention_period" => "1",
                  "backup_window" => "23:00-23:30",
                  "db_subnet_group_name" => "hogedb-subnet",
                  "endpoint" => "hogefuga.ap-northeast-1.rds.amazonaws.com",
                  "engine" => "postgres",
                  "engine_version" => "9.4.1",
                  "final_snapshot_identifier" => "hogedb-final",
                  "id" => "hogedb",
                  "identifier" => "hogedb",
                  "instance_class" => "db.m3.large",
                  "maintenance_window" => "mon:00:00-mon:00:30",
                  "multi_az" => "false",
                  "name" => "hogedb",
                  "parameter_group_name" => "default.postgres9.4",
                  "password" => "xxxxxxxx",
                  "port" => "5432",
                  "publicly_accessible" => "false",
                  "security_group_names.#" => "0",
                  "status" => "available",
                  "storage_type" => "standard",
                  "username" => "user",
                  "vpc_security_group_ids.#" => "1",
                }
              }
            },
          })
        end
      end
    end
  end
end

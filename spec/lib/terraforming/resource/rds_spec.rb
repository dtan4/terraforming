require "spec_helper"

module Terraforming::Resource
  describe RDS do
    let(:json) do
      JSON.parse(open(fixture_path("rds/describe-db-instances")).read)
    end

    describe ".tf" do
      it "should generate tf" do
        expect(described_class.tf(json)).to eq <<-EOS
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
        expect(described_class.tfstate(json)).to eq JSON.pretty_generate({
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
          }
        })
      end
    end
  end
end

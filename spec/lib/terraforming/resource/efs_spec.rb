require "spec_helper"

module Terraforming
  module Resource
    describe EFSFileSystem do
      let(:client) do
        Aws::EFS::Client.new(stub_responses: true)
      end

      let(:efs_description_0) do
        {
          creation_time: Time.parse("2016-11-01 11:30:00 -0700"),
          creation_token: "console-1234abcd-1234-abcd-a123-d34db33f0000",
          file_system_id: "fs-0000abcd",
          life_cycle_state: "available",
          name: "efs_name_0",
          number_of_mount_targets: 3,
          owner_id: "999999999999",
          performance_mode: "generalPurpose",
          size_in_bytes: { value: 6144 },
        }
      end

      let(:efs_description_1) do
        {
          creation_time: Time.parse("2016-10-24 11:42:21 -0700"),
          creation_token: "console-0000abcd-4321-dcba-a123-d34db33f0000",
          file_system_id: "fs-abcd1234",
          life_cycle_state: "available",
          name: "efs_name_1",
          number_of_mount_targets: 3,
          owner_id: "999999999999",
          performance_mode: "generalPurpose",
          size_in_bytes: { value: 23481234 },
        }
      end

      before do
        client.stub_responses(:describe_file_systems, file_systems: [efs_description_0, efs_description_1])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_efs_file_system" "fs-0000abcd" {
    creation_token = "console-1234abcd-1234-abcd-a123-d34db33f0000"
    file_system_id = "fs-0000abcd"
    performance_mode = "generalPurpose"
    tags {
        Name = "efs_name_0"
    }
}
resource "aws_efs_file_system" "fs-abcd1234" {
    creation_token = "console-0000abcd-4321-dcba-a123-d34db33f0000"
    file_system_id = "fs-abcd1234"
    performance_mode = "generalPurpose"
    tags {
        Name = "efs_name_1"
    }
}
        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_efs_file_system.fs-0000abcd" => {
               "type"         => "aws_efs_file_system",
               "depends_on"   => [],
               "primary"      => {
                 "id"         => "fs-0000abcd",
                 "meta"       => {},
                 "tainted"    => false,
                 "attributes" => {
                   "creation_token"   => "console-1234abcd-1234-abcd-a123-d34db33f0000",
                   "id"               => "fs-0000abcd",
                   "performance_mode" => "generalPurpose",
                   "tags.%"           => "1",
                   "tags.Name"        => "efs_name_0"
                 },
               },
               "deposed"  => [],
               "provider" => "aws",
            },
            "aws_efs_file_system.fs-abcd1234" => {
               "type"         => "aws_efs_file_system",
               "depends_on"   => [],
               "primary"      => {
                 "id"         => "fs-abcd1234",
                 "meta"       => {},
                 "tainted"    => false,
                 "attributes" => {
                    "creation_token"   => "console-0000abcd-4321-dcba-a123-d34db33f0000",
                    "id"               => "fs-abcd1234",
                    "performance_mode" => "generalPurpose",
                    "tags.%"           => "1",
                    "tags.Name"        => "efs_name_1"
                 },
               },
               "deposed"  => [],
               "provider" => "aws",
            }
          })
        end
      end
    end
  end
end

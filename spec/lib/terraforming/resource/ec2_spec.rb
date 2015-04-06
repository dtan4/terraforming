require "spec_helper"

module Terraforming::Resource
  describe EC2 do
    let(:client) do
      Aws::EC2::Client.new(stub_responses: true)
    end

    let(:instances) do
      [
        {
          instance_id: "i-1234abcd",
          image_id: "ami-1234abcd",
          state: { code: 16, name: "running" },
          private_dns_name: "ip-10-0-0-100.ap-northeast-1.compute.internal",
          public_dns_name: "ec2-54-12-0-0.ap-northeast-1.compute.amazonaws.com",
          state_transition_reason: "",
          key_name: "hoge-key",
          ami_launch_index: 0,
          product_codes: [],
          instance_type: "t2.micro",
          launch_time: Time.parse("2015-03-12 01:23:45 UTC"),
          placement: { availability_zone: "ap-northeast-1b", group_name: "", tenancy: "default" },
          monitoring: { state: "disabled" },
          subnet_id: "subnet-1234abcd",
          vpc_id: "vpc-1234abcd",
          private_ip_address: "10.0.0.100",
          public_ip_address: "54.12.0.0",
          architecture: "x86_64",
          root_device_type: "ebs",
          root_device_name: "/dev/sda1",
          block_device_mappings: [
            {
              device_name: "/dev/sda1",
              ebs: {
                volume_id: "vol-1234abcd", status: "attached",
                attach_time: Time.parse("2015-03-12 01:23:45 UTC"), delete_on_termination: true
              }
            }
          ],
          virtualization_type: "hvm",
          client_token: "abcde1234567890123",
          tags: [
            { key: "Name", value: "hoge" }
          ],
          security_groups: [
            { group_name: "default", group_id: "sg-1234abcd" }
          ],
          source_dest_check: true,
          hypervisor: "xen",
          network_interfaces: [
            {
              network_interface_id: "eni-1234abcd",
              subnet_id: "subnet-1234abcd",
              vpc_id: "vpc-1234abcd",
              description: "Primary network interface",
              owner_id: "012345678901",
              status: "in-use",
              mac_address: "01:23:45:67:89:0a",
              private_ip_address: "10.0.0.100",
              private_dns_name: "ip-10-0-0-100.ap-northeast-1.compute.internal",
              source_dest_check: true,
              groups: [
                { group_name: "default", group_id: "sg-1234abcd" }
              ],
              attachment: {
                attachment_id: "eni-attach-5678efgh",
                device_index: 0,
                status: "attached",
                attach_time: Time.parse("2015-03-12 01:23:45 UTC"),
                delete_on_termination: true
              },
              association: {
                public_ip: "54.12.0.0",
                public_dns_name: "ec2-54-12-0-0.ap-northeast-1.compute.amazonaws.com",
                ip_owner_id: "amazon"
              },
              private_ip_addresses: [
                {
                  private_ip_address: "10.0.0.100",
                  private_dns_name: "ip-10-0-6-100.ap-northeast-1.compute.internal",
                  primary: true,
                  association: {
                    public_ip: "54.12.0.0",
                    public_dns_name: "ec2-54-12-0-0.ap-northeast-1.compute.amazonaws.com",
                    ip_owner_id: "amazon"
                  }
                }
              ]
            }
          ],
          ebs_optimized: false
        }
      ]
    end

    let(:reservations) do
      [
        reservation_id: "r-1234abcd",
        owner_id: "012345678901",
        requester_id: nil,
        groups: [],
        instances: instances
      ]
    end

    before do
      client.stub_responses(:describe_instances, reservations: reservations)
    end

    describe ".tf" do
      it "should generate tf" do
        expect(described_class.tf(client)).to eq <<-EOS
resource "aws_instance" "hoge" {
    ami                         = "ami-1234abcd"
    availability_zone           = "ap-northeast-1b"
    ebs_optimized               = false
    instance_type               = "t2.micro"
    key_name                    = "hoge-key"
    security_groups             = ["sg-1234abcd"]
    subnet_id                   = "subnet-1234abcd"
    associate_public_ip_address = true
    private_ip                  = "10.0.0.100"
    source_dest_check           = true

    ebs_block_device {
        device_name = "/dev/sda1"
    }

    tags {
        Name = "hoge"
    }
}

        EOS
      end
    end

    describe ".tfstate" do
      it "should generate tfstate" do
        expect(described_class.tfstate(client)).to eq JSON.pretty_generate({
          "aws_instance.hoge"=> {
            "type"=> "aws_instance",
            "primary"=> {
              "id"=> "i-1234abcd",
              "attributes"=> {
                "ami"=> "ami-1234abcd",
                "associate_public_ip_address"=> "true",
                "availability_zone"=> "ap-northeast-1b",
                "ebs_block_device.#"=> "1",
                "ebs_optimized"=> "false",
                "ephemeral_block_device.#"=> "0",
                "id"=> "i-1234abcd",
                "instance_type"=> "t2.micro",
                "private_dns"=> "ip-10-0-0-100.ap-northeast-1.compute.internal",
                "private_ip"=> "10.0.0.100",
                "public_dns"=> "ec2-54-12-0-0.ap-northeast-1.compute.amazonaws.com",
                "public_ip"=> "54.12.0.0",
                "root_block_device.#"=> "1",
                "security_groups.#"=> "1",
                "source_dest_check"=> "true",
                "subnet_id"=> "subnet-1234abcd",
                "tenancy"=> "default"
              },
              "meta"=> {
                "schema_version"=> "1"
              }
            }
          }
        })
      end
    end
  end
end

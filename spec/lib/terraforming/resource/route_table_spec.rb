require "spec_helper"

module Terraforming
  module Resource
    describe RouteTable do
      let(:client) do
        Aws::EC2::Client.new(stub_responses: true)
      end

      let(:route_tables) do
        [
          {
            route_table_id: 'rtb-a12bcd34',
            vpc_id: 'vpc-ab123cde',
            routes: [
              {
                destination_cidr_block: '10.0.0.0/16',
                destination_prefix_list_id: nil,
                gateway_id: 'local',
                instance_id: nil,
                instance_owner_id: nil,
                network_interface_id: nil,
                vpc_peering_connection_id: nil,
                state: 'active'
              },
              {
                destination_cidr_block: '0.0.0.0/0',
                destination_prefix_list_id: nil,
                gateway_id: 'igw-1ab2345c',
                instance_id: nil,
                instance_owner_id: nil,
                network_interface_id: nil,
                vpc_peering_connection_id: nil,
                state: 'active'
              },
              {
                destination_cidr_block: '192.168.1.0/24',
                destination_prefix_list_id: nil,
                gateway_id: nil,
                instance_id: 'i-ec12345a',
                instance_owner_id: nil,
                network_interface_id: nil,
                vpc_peering_connection_id: nil,
                state: 'active'
              },
              {
                destination_cidr_block: '192.168.2.0/24',
                destination_prefix_list_id: nil,
                gateway_id: nil,
                instance_id: nil,
                instance_owner_id: nil,
                network_interface_id: nil,
                vpc_peering_connection_id: 'pcx-c56789de',
                state: 'active'
              }
            ],
            associations: [
              {
                route_table_association_id: 'rtbassoc-b123456cd',
                route_table_id: 'rtb-a12bcd34',
                subnet_id: 'subnet-1234a567',
                main: false
              },
              {
                route_table_association_id: 'rtbassoc-e789012fg',
                route_table_id: 'rtb-e56egf78',
                subnet_id: 'subnet-8901b123',
                main: false
              }
            ],
            tags: [
              {
                key: 'Name',
                value: 'my-route-table'
              }
            ]
          },
          {
            route_table_id: 'rtb-efgh5678',
            vpc_id: 'vpc-ab123cde',
            routes: [
              {
                destination_cidr_block: '0.0.0.0/0',
                destination_prefix_list_id: nil,
                gateway_id: 'vgw-2345cdef',
                instance_id: nil,
                instance_owner_id: nil,
                network_interface_id: nil,
                vpc_peering_connection_id: nil,
                state: 'active'
              }
            ],
            associations: [
            ],
            tags: [
              {
                key: 'Name',
                value: 'my-route-table-2'
              }
            ]
          }
        ]
      end

      before do
        client.stub_responses(:describe_route_tables, route_tables: route_tables)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_route_table" "my-route-table" {
    vpc_id     = "vpc-ab123cde"

    route {
        cidr_block = "10.0.0.0/16"
        gateway_id = "local"
    }

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "igw-1ab2345c"
    }

    route {
        cidr_block = "192.168.1.0/24"
        instance_id = "i-ec12345a"
    }

    route {
        cidr_block = "192.168.2.0/24"
        vpc_peering_connection_id = "pcx-c56789de"
    }

    tags {
        "Name" = "my-route-table"
    }
}

resource "aws_route_table" "my-route-table-2" {
    vpc_id     = "vpc-ab123cde"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "vgw-2345cdef"
    }

    tags {
        "Name" = "my-route-table-2"
    }
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_route_table.my-route-table" => {
              "type" => "aws_route_table",
              "primary" => {
                "id" => "rtb-a12bcd34",
                "attributes" => {
                  "id" => "rtb-a12bcd34",
                  "route.#" => "4",
                  "tags.#" => "1",
                  "vpc_id" => "vpc-ab123cde",
                }
              }
            },
            "aws_route_table.my-route-table-2" => {
              "type" => "aws_route_table",
              "primary" => {
                "id"=>"rtb-efgh5678",
                "attributes" => {
                  "id" => "rtb-efgh5678",
                  "route.#" => "1",
                  "tags.#" => "1",
                  "vpc_id" => "vpc-ab123cde"
                }
              }
            }
          })
        end
      end
    end
  end
end

require "spec_helper"

module Terraforming
  module Resource
    describe RouteTableAssociation do
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
                route_table_id: 'rtb-a12bcd34',
                subnet_id: 'subnet-8901b123',
                main: false
              },
              {
                route_table_association_id: 'rtbassoc-e71201aaa',
                route_table_id: 'rtb-a12bcd34',
                subnet_id: nil,
                main: true
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
resource "aws_route_table_association" "my-route-table-rtbassoc-b123456cd" {
    route_table_id = "rtb-a12bcd34"
    subnet_id = "subnet-1234a567"
}

resource "aws_route_table_association" "my-route-table-rtbassoc-e789012fg" {
    route_table_id = "rtb-a12bcd34"
    subnet_id = "subnet-8901b123"
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_route_table_association.my-route-table-rtbassoc-b123456cd" => {
              "type" => "aws_route_table_association",
              "primary" => {
                "id" => "rtbassoc-b123456cd",
                "attributes" => {
                  "id" => "rtbassoc-b123456cd",
                  "route_table_id" => "rtb-a12bcd34",
                  "subnet_id" => "subnet-1234a567"
                }
              }
            },
            "aws_route_table_association.my-route-table-rtbassoc-e789012fg" => {
              "type" => "aws_route_table_association",
              "primary" => {
                "id" => "rtbassoc-e789012fg",
                "attributes" => {
                  "id" => "rtbassoc-e789012fg",
                  "route_table_id" => "rtb-a12bcd34",
                  "subnet_id" => "subnet-8901b123"
                }
              }
            }
          })
        end
      end
    end
  end
end

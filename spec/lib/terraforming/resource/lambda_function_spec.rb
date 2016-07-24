require "spec_helper"

module Terraforming
  module Resource
    describe LambdaFunction do
      let(:client) do
        Aws::Lambda::Client.new(stub_responses: true)
      end

      let(:list_lambdas) do
        [
            { function_name: "lambda_func_1" }
        ]
      end

      let(:get_lambda_without_vpc) do
        [
            {
                configuration: {
                  function_name: "lambda_func_1",
                  role: "arn:aws:iam::123456789012:role/lambdatest",
                  handler: "lambda_test",
                  description: "Lambda Test Description",
                  memory_size: 128,
                  runtime: "python2.7",
                  timeout: 3,
                  last_modified: Time.new(2015, 10, 31, 2, 2, 2),
                },
                code: {
                  location: "http://localhost/file.zip"
                }
            }
        ]
      end

      let(:get_lambda_with_vpc) do
        [
            {
                configuration: {
                    function_name: "lambda_func_2",
                    role: "arn:aws:iam::123456789012:role/lambdatest",
                    handler: "lambda_test",
                    description: "Lambda Test Description",
                    memory_size: 128,
                    runtime: "python2.7",
                    timeout: 3,
                    last_modified: Time.new(2015, 10, 31, 2, 2, 2),
                    vpc_config: {
                        subnet_ids: ['subnet-12345678'],
                        security_group_ids: ['sg-12345678'],
                        vpc_id: 'vpc-12345678'
                    }
                },
                code: {
                    location: "http://localhost/file.zip"
                }
            }
        ]
      end

      before do
        allow_any_instance_of(Net::HTTP).to receive(:start)
          .and_yield(Net::HTTP)
        allow(Net::HTTP).to receive(:get).and_return(Net::HTTPResponse)
        allow(Net::HTTPResponse).to receive(:code).and_return("200")
        allow(Net::HTTPResponse).to receive(:body)
          .and_return("Lambda Content")

        client.stub_responses(:list_functions, functions: list_lambdas)
      end

      describe ".tfstate" do
        it "should generate tfstate for Lambda not in a VPC" do
          client.stub_responses(:get_function, get_lambda_without_vpc)
          expect(described_class.tfstate(client: client)).to eq({
            "aws_lambda_function.lambda_func_1" => {
                "type" => "aws_lambda_function",
                "primary" => {
                    "id" => "lambda_func_1",
                    "attributes" => {
                        "arn" => nil,
                        "description" => "Lambda Test Description",
                        "filename" => "lambda_func_1.zip",
                        "function_name" => "lambda_func_1",
                        "handler" => "lambda_test",
                        "id" => "lambda_func_1",
                        "last_modified" => Time.new(2015, 10, 31, 2, 2, 2)
                                               .strftime("%FT%T%z"),
                        "memory_size" => "128",
                        "role" => "arn:aws:iam::123456789012:role/lambdatest",
                        "runtime" => "python2.7",
                        "source_code_hash" => nil,
                        "timeout" => "3",
                    }
                }
            },
        })
        end

        it "should generate tfstate for Lambda in a VPC" do
          client.stub_responses(:get_function, get_lambda_with_vpc)
          expect(described_class.tfstate(client: client)).to eq({
            "aws_lambda_function.lambda_func_2" => {
                "type" => "aws_lambda_function",
                "primary" => {
                    "id" => "lambda_func_2",
                    "attributes" => {
                        "arn" => nil,
                        "description" => "Lambda Test Description",
                        "filename" => "lambda_func_2.zip",
                        "function_name" => "lambda_func_2",
                        "handler" => "lambda_test",
                        "id" => "lambda_func_2",
                        "last_modified" => Time.new(2015, 10, 31, 2, 2, 2)
                                               .strftime("%FT%T%z"),
                        "memory_size" => "128",
                        "role" => "arn:aws:iam::123456789012:role/lambdatest",
                        "runtime" => "python2.7",
                        "source_code_hash" => nil,
                        "timeout" => "3",
                        "vpc_config.#" => "1",
                        "vpc_config.0.security_group_ids.#" => "1",
                        "vpc_config.0.security_group_ids.3003185701" =>
                            "sg-12345678",
                        "vpc_config.0.subnet_ids.#" => "1",
                        "vpc_config.0.subnet_ids.1404027315" =>
                            "subnet-12345678"
                    }
                }
            },
        })
        end
      end

      describe ".tf" do
        it "should generate tf for Lambda not in a VPC" do
          buffer = StringIO.new
          allow(File).to receive(:open).and_yield(buffer)

          client.stub_responses(:get_function, get_lambda_without_vpc)
          expect(described_class.tf(client: client)).to eq <<-EOF
resource "aws_lambda_function" "lambda_func_1" {
    filename = "lambda_func_1.zip"
    function_name = "lambda_func_1"
    role = "arn:aws:iam::123456789012:role/lambdatest"
    handler = "lambda_test"
    description = "Lambda Test Description"
    memory_size = "128"
    runtime = "python2.7"
    timeout = "3"
    source_code_hash = ""
}
          EOF
        end

        it "should generate tf for Lambda in a VPC" do
          buffer = StringIO.new
          allow(File).to receive(:open).and_yield(buffer)

          client.stub_responses(:get_function, get_lambda_with_vpc)
          expect(described_class.tf(client: client)).to eq <<-EOF
resource "aws_lambda_function" "lambda_func_2" {
    filename = "lambda_func_2.zip"
    function_name = "lambda_func_2"
    role = "arn:aws:iam::123456789012:role/lambdatest"
    handler = "lambda_test"
    description = "Lambda Test Description"
    memory_size = "128"
    runtime = "python2.7"
    timeout = "3"
    source_code_hash = ""
    vpc_config {
        subnet_ids = ["subnet-12345678"]
        security_group_ids = ["sg-12345678"]
    }
}
          EOF
        end

        it "should save lambda function to local file" do
          buffer = StringIO.new
          allow(File).to receive(:open).and_yield(buffer)
          described_class.tf(client: client)
          expect(buffer.string).to eq "Lambda Content"
        end
      end
    end
  end
end

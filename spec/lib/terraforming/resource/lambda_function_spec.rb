require "spec_helper"

module Terraforming
  module Resource
    describe LambdaFunction do
      let(:client) do
        Aws::Lambda::Client.new(stub_responses: true)
      end

      let(:lambdas) do
        [
            {
                function_name: "LambdaFunc1"
            },
            {
                function_name: "LambdaFunc2"
            }
        ]
      end

      context "without vpc" do
        before do
          puts "================"
          puts lambdas
          puts "=================="
          client.stub_responses(:list_functions, functions:lambdas)

        end

        describe ".tf" do
          it "should generate tf" do
            puts "runner"
            allow_any_instance_of(Net::HTTP).to receive(:start).and_return(true)
            allow(Net::HTTP).to receive(:get).and_return(Net::HTTPResponse)
            allow(Net::HTTPResponse).to receive(:code).and_return("200")
            allow(Net::HTTPResponse).to receive(:body).and_return('never used')

            expect(described_class.tf(client: client)).to eq <<-EOF
resource "aws_lambda_function" "LamdaFunc1" {
    filename = ""
    function_name = "LamdaFunc1"
    role = ""
    handler = ""
    description = ""
    memory_size = ""
    runtime = ""
    timeout = ""
    source_code_hash = ""
}
          EOF

          end
        end
      end
    end
  end
end

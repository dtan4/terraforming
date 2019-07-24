require "spec_helper"

module Terraforming
  module Resource
    describe BatchJobQueue do
      let(:client) do
        Aws::Batch::Client.new(stub_responses: true)
      end

      let(:queues) do
        [
          {
            compute_environment_order: [
              {
                compute_environment: "arn:aws:batch:us-east-1:012345678910:compute-environment/C4OnDemand",
                order: 1,
              },
            ],
            job_queue_arn: "arn:aws:batch:us-east-1:012345678910:job-queue/HighPriority",
            job_queue_name: "HighPriority",
            priority: 1,
            state: "ENABLED",
            status: "VALID",
            status_reason: "JobQueue Healthy",
          },
          {
            compute_environment_order: [
              {
                compute_environment: "M4Spot",
                order: 1,
              },
            ],
            job_queue_name: "LowPriority",
            priority: 10,
            state: "DISABLE",
          }
        ]
      end

      before do
        client.stub_responses(:describe_job_queues, job_queues: queues)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<-EOS
resource "aws_batch_job_queue" "HighPriority" {
  name                 = "HighPriority"
  priority             = 1
  state                = "ENABLED"
  compute_environments = ["arn:aws:batch:us-east-1:012345678910:compute-environment/C4OnDemand"]
}

resource "aws_batch_job_queue" "LowPriority" {
  name                 = "LowPriority"
  priority             = 10
  state                = "DISABLE"
  compute_environments = ["M4Spot"]
}

        EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
            "aws_batch_job_queue.HighPriority" => {
              "type" => "aws_batch_job_queue",
              "primary" => {
                "id" => "HighPriority",
                "attributes" => {
                  "name" => "HighPriority",
                  "priority" => "1",
                  "state" => "ENABLED",
                  "compute_environments.order" => "1",
                  "compute_environments.compute_environment" => "arn:aws:batch:us-east-1:012345678910:compute-environment/C4OnDemand"
                }
              }
            },
            "aws_batch_job_queue.LowPriority" => {
              "type" => "aws_batch_job_queue",
              "primary" => {
                "id" => "LowPriority",
                "attributes" => {
                  "name" => "LowPriority",
                  "priority" => "10",
                  "state" => "DISABLE",
                  "compute_environments.order" => "1",
                  "compute_environments.compute_environment" => "M4Spot"
                }
              }
            }
          })
        end
      end
    end
  end
end

module Terraforming
  module Resource
    class BatchJobQueue
      include Terraforming::Util

      def self.tf(client: Aws::Batch::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::Batch::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/batch_job_queue")
      end

      def tfstate
        queues.inject({}) do |resources, queue|
          attributes = {
            "arn" => queue.job_queue_arn,
            "id" => queue.job_queue_arn,
            "name" => queue.job_queue_name,
            "priority" => queue.priority.to_s,
            "state" => queue.state,
          }

          attributes.merge!(compute_environments_attributes_of(queue))

          resources["aws_batch_job_queue.#{module_name_of(queue)}"] = {
            "type" => "aws_batch_job_queue",
            "primary" => {
              "id" => queue.job_queue_arn,
              "attributes" => attributes
            }
          }
          resources
        end
      end

      private

      def queues
        @client.describe_job_queues.map(&:job_queues).flatten
      end

      def module_name_of(queue)
        normalize_module_name(queue.job_queue_name)
      end

      def compute_environments_attributes_of(queue)
        attributes = { "compute_environments.#" => queue.compute_environment_order.length.to_s }

        queue.compute_environment_order.each do |compute_environment|
          attributes.merge!(compute_environment_attributes_of(compute_environment))
        end

        attributes
      end

      def compute_environment_attributes_of(compute_environment)
        attributes = {
          "compute_environments.#{compute_environment.order.to_s}" => compute_environment.compute_environment
        }

        attributes
      end
    end
  end
end

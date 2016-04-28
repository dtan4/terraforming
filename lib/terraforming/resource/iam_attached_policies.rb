module Terraforming
  module Resource
    class IAMAttachedPolicies
      include Terraforming::Util
;
      def self.tf(client: Aws::IAM::Client.new)
        self.new(client).tf
      end

      def self.tfstate(client: Aws::IAM::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/iam_attached_policies")
      end

      def tfstate
        iam_policies.inject({}) do |resources, policy|
        #TODO:
        end
      end

      private

      def iam_policies_map()
        policies = Hash.new
        [:user, :group, :role].each do |type|
          list = @client.send("list_#{type}s")["#{type}s"]
          list.each do |resource|
            resource_name = resource["#{type}_name"]
            attached = @client.send("list_attached_#{type}_policies", "#{type}_name": resource_name).attached_policies
            attached.each do |policy|
              unless policies.key? policy.policy_name then
                policies[policy.policy_name] = {
                    policy_arn: policy.policy_arn,
                    user:  Set.new,
                    group: Set.new,
                    role:  Set.new,
                }
              end

              policy_entry = policies[policy.policy_name]
              policy_entry[type].add(resource_name)
            end
          end
        end
        return policies
      end

    end
  end
end

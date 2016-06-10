module Terraforming
  module Resource
    class IAMPolicyAttachment
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
        apply_template(@client, "tf/iam_policy_attachment")
      end

      def tfstate
        iam_policies_map.inject({}) do |resources, (name, policy)|
          attributes = {
            "id"         => "#{name}-attach",
            "name"       => "#{name}-attach",
            "users.#"    => policy[:user].size().to_s,
            "groups.#"   => policy[:group].size().to_s,
            "roles.#"    => policy[:role].size().to_s,
            "policy_arn" => policy[:policy_arn],
          }
          resources["aws_iam_policy_attachment.#{name}-attachments"] = {
            "type" => "aws_iam_policy_attachment",
            "primary" => {
              "id"         => "#{name}-attach",
              "attributes" => attributes,
            }
          }

          resources
        end
      end

      private

      def iam_policies_map
        policies = Hash.new
        [:user, :group, :role].each do |type|
          list = @client.send("list_#{type}s")["#{type}s"]
          list.each do |resource|
            resource_name = resource["#{type}_name"]
            attached = @client.send("list_attached_#{type}_policies", :"#{type}_name" => resource_name).attached_policies
            attached.each do |policy|
              unless policies.key? policy.policy_name
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

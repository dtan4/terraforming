module Terraforming::Resource
  class SecurityGroup
    def self.tf(client = Aws::EC2::Client.new)
      Terraforming::Resource.apply_template(client, "tf/security_group")
    end

    def self.tfstate(client = Aws::EC2::Client.new)
      # TODO: implement SecurityGroup.tfstate
      raise NotImplementedError
    end
  end
end

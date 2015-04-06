module Terraforming::Resource
  class SecurityGroup
    def self.tf(client = Aws::EC2::Client.new)
      ERB.new(open(Terraforming.template_path("tf/security_group")).read, nil, "-").result(binding)
    end

    def self.tfstate(client = Aws::EC2::Client.new)
      # TODO: implement SecurityGroup.tfstate
      raise NotImplementedError
    end
  end
end

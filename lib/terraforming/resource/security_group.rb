module Terraforming::Resource
  class SecurityGroup
    def self.tf(data)
      ERB.new(open(Terraforming.template_path("tf/security_group")).read, nil, "-").result(binding)
    end

    def self.tfstate(data)
      # TODO: implement SecurityGroup.tfstate
      raise NotImplementedError
    end
  end
end

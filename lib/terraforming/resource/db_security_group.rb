module Terraforming::Resource
  class DBSecurityGroup
    def self.tf(data)
      ERB.new(open(Terraforming.template_path("tf/db_security_group")).read).result(binding)
    end

    def self.tfstate(data)
      # TODO: implement DBSecurityGroup.tfstate
      raise NotImplementedError
    end
  end
end

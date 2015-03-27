module Terraforming::Resource
  class DBSubnetGroup
    def self.tf(data)
      ERB.new(open(Terraforming.template_path("tf/db_subnet_group")).read).result(binding)
    end

    def self.tfstate(data)
      # TODO: implement DBSubnetGroup.tfstate
      raise NotImplementedError
    end
  end
end

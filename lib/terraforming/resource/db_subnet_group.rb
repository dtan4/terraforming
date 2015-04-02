module Terraforming::Resource
  class DBSubnetGroup
    def self.tf(client = Aws::RDS::Client.new)
      ERB.new(open(Terraforming.template_path("tf/db_subnet_group")).read, nil, "-").result(binding)
    end

    def self.tfstate(client = Aws::RDS::Client.new)
      # TODO: implement DBSubnetGroup.tfstate
      raise NotImplementedError
    end
  end
end

module Terraforming::Resource
  class EC2
    def self.tf(data)
      ERB.new(open(Terraforming.template_path("tf/ec2")).read, nil, "-").result(binding)
    end

    def self.tfstate(data)
      # TODO: implement this
      raise NotImplementedError
    end
  end
end

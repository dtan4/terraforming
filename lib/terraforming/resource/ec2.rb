module Terraforming::Resource
  class EC2
    def self.tf(data)
      Terraforming::Resource.apply_template(client, "tf/ec2")
    end

    def self.tfstate(data)
      # TODO: implement this
      raise NotImplementedError
    end
  end
end

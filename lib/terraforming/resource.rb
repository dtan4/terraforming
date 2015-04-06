module Terraforming::Resource
  def self.apply_template(client, erb)
    ERB.new(open(Terraforming.template_path(erb)).read, nil, "-").result(binding)
  end
end

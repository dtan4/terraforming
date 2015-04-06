module Terraforming::Resource
  def self.apply_template(client, erb)
    ERB.new(open(template_path(erb)).read, nil, "-").result(binding)
  end

  def self.template_path(template_name)
    File.join(File.expand_path(File.dirname(__FILE__)), "template", template_name) << ".erb"
  end
end

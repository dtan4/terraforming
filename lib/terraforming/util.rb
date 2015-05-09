module Terraforming
  module Util
    def apply_template(client, erb)
      ERB.new(open(template_path(erb)).read, nil, "-").result(binding)
    end

    def name_from_tag(resource, default_name)
      name_tag = resource.tags.find { |tag| tag.key == "Name" }
      name_tag ? name_tag.value : default_name
    end

    def normalize_module_name(name)
      name.gsub(/[^a-zA-Z0-9_-]/, "-")
    end

    def template_path(template_name)
      File.join(File.expand_path(File.dirname(__FILE__)), "template", template_name) << ".erb"
    end

    def generate_tfstate(resources)
      tfstate = {
        "version" => 1,
        "serial" => 1,
        "modules" => {
          "path" => [
            "root"
          ],
          "outputs" => {},
          "resources" => resources
        }
      }

      JSON.pretty_generate(tfstate)
    end
  end
end

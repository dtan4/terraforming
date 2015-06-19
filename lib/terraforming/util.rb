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

    def generate_tfstate(resources, tfstate_base = nil)
      tfstate = tfstate_base || tfstate_skeleton
      tfstate["modules"][0]["resources"] = tfstate["modules"][0]["resources"].merge(resources)
      JSON.pretty_generate(tfstate)
    end

    def prettify_policy(policy_document, breakline = false)
      json = JSON.pretty_generate(JSON.parse(CGI.unescape(policy_document)))

      if breakline
        json[-1] != "\n" ? json << "\n" : json
      else
        json.strip
      end
    end

    def tfstate_skeleton
      {
        "version" => 1,
        "serial" => 1,
        "modules" => [
          {
            "path" => [
              "root"
            ],
            "outputs" => {},
            "resources" => {},
          }
        ]
      }
    end
  end
end

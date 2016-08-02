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

    def prettify_policy(document, breakline: false, unescape: false)
      json = JSON.pretty_generate(JSON.parse(unescape ? CGI.unescape(document) : document))

      if breakline
        json[-1] != "\n" ? json << "\n" : json
      else
        json.strip
      end
    end
  end
end

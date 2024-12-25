# frozen_string_literal: true

require "render_anywhere"

module WebClient
  class TemplateCompiler
    include RenderAnywhere

    def self.compile
      new.compile
    end

    def compile
      write_sprockets_headers unless Rails.env.production?

      angular_module = "tv-dashboard"
      set_render_anywhere_helpers DomainHelper
      set_render_anywhere_helpers RenderComponentHelper
      set_render_anywhere_helpers FormHelper
      set_render_anywhere_helpers ImageHelper
      %!angular.module("#{angular_module}").run(["$templateCache", function($templateCache) {#{angular_templates}}]);!
    end

    def angular_templates(path: WebClient::Engine.root.join("app", "assets", "components"))
      Dir[File.join(path, "**/_*.html.slim")].map do |absolute_path|
        template = template_name absolute_path, path
        template_name = template.sub "/template", ""

        template_content = with_cache(absolute_path) do
          render(partial: template).gsub('"', '\"').gsub("\n", "")
        end

        %!$templateCache.put("#{template_name}.html", "#{template_content}");!
      end.join("\n")
    end

    def headers(path: WebClient::Engine.root.join("app", "assets", "components"))
      Dir[File.join(path, "**/*.slim")].sort.map do |absolute_path|
        template = template_header absolute_path, path
        "//= depend_on #{template}"
      end.join("\n")
    end

    def with_cache(absolute_path, &block)
      return block.call # if Rails.env.production?
      is_recent = File.mtime(absolute_path) >= 10.seconds.ago
      if is_recent
        block.call.tap do |new_content|
          Rails.cache.write absolute_path, new_content
        end
      else
        Rails.cache.fetch absolute_path do
          block.call
        end
      end
    end

    private

    def template_name(template, path)
      template =~ %r{#{path}/(.+/)?_([^.]+)\.*}
      "#{Regexp.last_match(1)}#{Regexp.last_match(2)}"
    end

    def template_header(template, path)
      template.sub("#{path}/", "")
    end

    def write_sprockets_headers
      path = "#{WebClient::Engine.root}/app/assets/javascripts/templates.js.erb.slim"
      content = [
        headers,
        "= raw WebClient::TemplateCompiler.compile"
      ].join "\n"

      File.write path, content
    end
  end
end

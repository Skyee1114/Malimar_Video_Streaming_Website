# frozen_string_literal: true

namespace :templates do
  desc "TODO"
  task compile: :environment do
    require "web_client/template_compiler"
    WebClient::TemplateCompiler.compile
  end

  desc "TODO"
  task remove: :environment do
  end
end

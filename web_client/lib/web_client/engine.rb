# frozen_string_literal: true

module WebClient
  class Engine < Rails::Engine
    # config.assets.paths << File.expand_path("../../app/assets/components", __FILE__)
    config.assets.precompile += ["web_client.js", "templates.js"]
    config.paths["app/views"].unshift("app/assets/components")
  end
end

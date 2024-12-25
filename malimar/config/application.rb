require File.expand_path("boot", __dir__)

# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

require_relative "../lib/delayed_inline_adapter"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Malimartv
  class Application < Rails::Application
    # ActionMailer
    # config.action_mailer.default_url_options = { host: ENV['DOMAIN'] }
    routes.default_url_options[:host] = ENV["DOMAIN"]
    config.active_record.schema_format = :sql
    config.active_record.raise_in_transactional_callbacks = true
    config.filter_parameters += %i[password password_confirmation cvv number expiry_month expiry_year]
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}").to_s]

    config.active_job.queue_adapter = :delayed_inline
  end
end

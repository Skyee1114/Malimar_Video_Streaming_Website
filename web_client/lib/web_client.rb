# frozen_string_literal: true

require "web_client/version"
require "web_client/engine"
require "slim-rails"
require "sass"
require "coffee-rails"
require "rails-sass-images"
require "pry" unless Rails.env.production?
require "autoprefixer-rails"
require "web_client/railtie"
require "web_client/template_compiler"
require "web_client/config"

require "ruby_flipper"
RubyFlipper.load(File.expand_path("web_client/features.rb", __dir__))

module WebClient
end

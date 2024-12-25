# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "web_client/version"

Gem::Specification.new do |spec|
  spec.name          = "web_client"
  spec.version       = WebClient::VERSION
  spec.authors       = ["Alexander Paramonov"]
  spec.email         = ["alexander.n.paramonov@gmail.com"]
  spec.summary       = " Web client for malimar.tv "
  spec.description   = " AngularJS application for malimar.tv "
  spec.homepage      = ""

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "~> 4.2.11.1"
  spec.add_dependency "slim-rails"

  spec.add_dependency "foundation-rails", "~> 5.5.2"
  spec.add_dependency "sass-rails", "~> 5.0.3"

  spec.add_dependency "autoprefixer-rails", "~> 7.2.6"
  spec.add_dependency "bigdecimal", "~> 1.4.2"
  spec.add_dependency "coffee-rails"
  spec.add_dependency "rails-sass-images", "~> 1.0.3"
  spec.add_dependency "render_anywhere"
  spec.add_dependency "ruby_flipper"
  spec.add_dependency "sprockets", "~> 2.12.3"
  spec.add_dependency "sprockets-rails", "~> 2.3.3"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "pry-rails"
  spec.add_development_dependency "puma"
  spec.add_development_dependency "rack-proxy"
  spec.add_development_dependency "rake", "~> 10.0"
end

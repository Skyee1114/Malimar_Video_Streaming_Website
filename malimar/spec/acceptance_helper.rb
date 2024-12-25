require "rails_helper"
require "rspec_api_documentation"
require "rspec_api_documentation/dsl"
require "aws-sdk"
require "support/vcr"

ENV["DOC_FORMAT"] ||= "json"
ENV["DOMAIN"] = ENV["DOCUMENTATION_DOMAIN"]
Rails.application.routes.default_url_options[:host] = ENV["DOCUMENTATION_DOMAIN"]
Rails.application.routes.default_url_options[:protocol] = "https"

RspecApiDocumentation.configure do |config|
  config.format = ENV["DOC_FORMAT"]
  config.curl_host = ENV["DOCUMENTATION_DOMAIN"]
  config.api_name = "#{ENV['COMPANY_NAME']} TV API"
  config.request_body_formatter = :json
  config.curl_headers_to_filter = %w[Host Cookie]
end

RSpec.configure do |config|
  config.extend SpecHelpers::CacheControl
end

Dir[Rails.root.join("spec/support/acceptance_shared_examples/**/*.rb")].each { |f| require f }

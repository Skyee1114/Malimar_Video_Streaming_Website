require 'spec_helper'
require 'dotenv'
Dotenv.load
require_relative '../token_service_app'

Dir.glob("#{File.dirname(__FILE__)}/support/spec_helpers/**/*.rb").each { |f| require f }

RSpec.configure do |config|
  config.include SpecHelpers::JsonResponse
end

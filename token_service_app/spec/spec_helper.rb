require 'rack/test'
require 'rspec'
require 'pry'

$: << File.expand_path('../models', File.dirname(__FILE__))
ENV['RACK_ENV'] = 'test'

module RSpecSinatra
  include Rack::Test::Methods
  def app() described_class end
end

RSpec.configure do |config|
  config.include RSpecSinatra
end

require "bundler/setup"
ENV["RAILS_ENV"] ||= "test"
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = false
  end

  config.default_formatter = "doc" if config.files_to_run.one?

  config.backtrace_exclusion_patterns << /gems/
end

require "pry"

$: << File.expand_path("../app", File.dirname(__FILE__))
$: << File.expand_path("../lib", File.dirname(__FILE__))
$: << File.expand_path("../config/initializers", File.dirname(__FILE__))

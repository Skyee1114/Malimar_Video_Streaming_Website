require "spec_helper"
require File.expand_path("../config/environment", __dir__)
require "rspec/rails"

Dir[Rails.root.join("spec/support/spec_helpers/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.suppress_messages do
  connection = ActiveRecord::Base.connection

  sql = File.read("db/structure.sql")
  statements = sql.split(/;$/)
  statements.pop # the last empty statement

  ActiveRecord::Base.transaction do
    statements.each do |statement|
      connection.execute(statement)
    end
  end
end

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.include FactoryGirl::Syntax::Methods
  config.include SpecHelpers::JsonResponse
  config.include SpecHelpers::Authentication
  config.include SpecHelpers::Fixtures
  config.include SpecHelpers::RequestCounter

  config.use_transactional_fixtures = true
end

WebMock.enable!

require "action_controller/http_authentication/bearer"
require_relative "bearer_authentication_specs"

describe ActionController::HttpAuthentication::Bearer do
  subject { described_class }
  it_behaves_like :bearer_authentication do
    let(:token_name) { "Bearer" }
  end
end

require "action_controller/http_authentication/google"
require_relative "bearer_authentication_specs"

describe ActionController::HttpAuthentication::Google do
  subject { described_class }

  it_behaves_like :bearer_authentication do
    let(:token_name) { "Google" }
  end
end

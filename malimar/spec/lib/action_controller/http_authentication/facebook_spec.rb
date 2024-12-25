require "action_controller/http_authentication/facebook"
require_relative "bearer_authentication_specs"

describe ActionController::HttpAuthentication::Facebook do
  subject { described_class }

  it_behaves_like :bearer_authentication do
    let(:token_name) { "Facebook" }
  end
end

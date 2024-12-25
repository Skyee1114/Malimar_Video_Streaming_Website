require "acceptance_helper"
require "factories/user"

resource "Sessions" do
  include_context :api, authenticate: false
  let!(:api_user) { create :user, :with_password, password: "secret" }
  before { sign_in api_user, basic: "secret" }

  module ResponseFields
    def self.included(example)
      example.with_options scope: :sessions do
        response_field :id,  "Bearer token"
      end
    end
  end

  post "/sessions" do
    response_field :sessions, "Session object"
    include ResponseFields

    it_behaves_like :guest_forbidden
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :sessions
    example_request "Create session" do
      explanation "Bearer or Basic authentication allowed"
      expect(status).to eq 201
    end

    describe "when authentication fails", response_fields: [] do
      let(:api_user) { build :user, :with_password, password: "invalid" }

      example_request "Authentication error" do
        expect(status).to eq 401
      end
    end
  end

  post "/sessions?include=user" do
    response_field :sessions,  "Session object"
    response_field :links,     "Embedded resources", scope: :sessions
    include ResponseFields

    it_behaves_like :guest_forbidden
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :sessions
    example_request "Create session and return authenticated user" do
      explanation "Bearer or Basic authentication allowed"
      expect(json_response[:sessions]).to include links: have_key(:user)
    end
  end
end

require "acceptance_helper"
require "factories/user"

resource "Users" do
  include_context :api

  module ResponseFields
    def self.included(example)
      example.with_options scope: :users do
        response_field :id,     "User id"
        response_field :email,  "User email"
        response_field :login,  "User login"
      end
    end
  end

  module ParameterFields
    def self.included(example)
      example.with_options scope: :users do
        parameter :email,     "User email"
        parameter :password,  "User desired password"
      end

      example.let(:email) { "alice@example.com" }
      example.let(:password) { "secret123456" }
    end
  end

  post "/users" do
    parameter :users, "User resource object"
    include ParameterFields

    response_field :users, "User resource object"
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :users

    example "Register new user" do
      expect do
        do_request
      end.to change { User::Local.count }.by +1
    end

    describe "when validation error occurs", response_fields: [] do
      include_context :error

      let(:password) { "" }
      example_request "Validation error"
    end
  end

  post "/users?include=session" do
    parameter :users, "User resource object"
    include ParameterFields

    response_field :users,  "User resource object"
    response_field :links,  "Embedded resources", scope: :users
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :users

    example_request "Register new user and return his session" do
      expect(json_response[:users]).to include links: have_key(:session)
    end
  end

  get "/users/:id" do
    include_context :api

    let!(:user) { create :user }
    let(:api_user) { user }

    parameter :id, "User id"
    let(:id) { user.id }

    response_field :users, "User resource object"
    include ResponseFields

    it_behaves_like :authentication_required
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :users
    example_request "Get user details" do
      expect(json_response[:users]).to include(
        email: user.email,
        id: user.id
      )
    end
  end

  put "/users/:id" do
    include_context :api

    let!(:user) { create :user }
    let(:api_user) { user }

    parameter :id, "User id"
    let(:id) { user.id }

    parameter :users, "User resource object"

    parameter :email,     "New user contact email",  scope: :users
    parameter :password,  "New user password",       scope: :users

    let(:email) { "alice@example.com" }
    let(:password) { "secret123456" }

    response_field :users, "User resource object"
    include ResponseFields

    it_behaves_like :authentication_required
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :users
    example_request "Update user details" do
      expect(json_response[:users]).to include(
        email: email,
        id: user.id
      )
    end
  end
end

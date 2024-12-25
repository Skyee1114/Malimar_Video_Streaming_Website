require "acceptance_helper"
require "factories/user"
require "support/shared_examples/requests"

resource "Passwords" do
  include SpecHelpers::Email
  include_context :api

  module ResponseFields
    def self.included(example)
      example.with_options scope: :passwords do
        response_field :email, "User email"
      end
    end
  end

  module ParameterFields
    def self.included(example)
      example.with_options scope: :passwords do
        parameter :login,  "User login"
      end
      example.let(:login) { user.login }
      example.let(:user) { create :user, :registered }
    end
  end

  post "/passwords" do
    parameter :passwords, "Password resource object"
    include ParameterFields

    response_field :passwords, "Password resource object"
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :passwords

    example "Create new password and sends the email" do
      expect do
        do_request
      end.to change { all_emails.count }.by +1
    end

    describe "when requesting reset for unexisting login", response_fields: [] do
      let(:user) { build :user }
      example_request "Create password with unexisting login" do
        expect(response_status).to eq 404
      end
    end
  end
end

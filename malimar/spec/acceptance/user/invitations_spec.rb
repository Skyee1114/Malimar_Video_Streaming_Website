require "acceptance_helper"
require "factories/user"

resource "Invitations" do
  include SpecHelpers::Email
  include_context :api

  module ResponseFields
    def self.included(example)
      example.with_options scope: :invitations do
        response_field :email, "User email"
      end
    end
  end

  module ParameterFields
    def self.included(example)
      example.with_options scope: :invitations do
        parameter :email,  "User email"
      end
      example.let(:email) { "alice@example.com" }
    end
  end

  post "/invitations" do
    parameter :invitations, "Invitation resource object"
    include ParameterFields

    response_field :invitations, "Invitation resource object"
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :invitations

    example "Create new invitaiton and sends the email" do
      expect do
        do_request
      end.to change { all_emails.count }.by +1
    end

    describe "when validation error occurs", response_fields: [] do
      include_context :error

      let(:email) { "invalid_email" }
      example_request "Create invitation with invalid email"
    end
  end
end

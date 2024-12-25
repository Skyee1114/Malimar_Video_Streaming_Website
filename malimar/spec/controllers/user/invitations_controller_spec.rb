require "rails_helper"
require "support/shared_examples/requests"
require "factories/invitation"

describe User::InvitationsController do
  include SpecHelpers::Email
  describe "create" do
    def do_request(**_attributes)
      post :create, format: :jsonapi, invitations: {
        email: resource.email
      }
    end

    let(:resource) { build :invitation }

    it_behaves_like :create_resource_request, name: :invitations, persisted: false do
      let(:respond_with) { { email: resource.email } }
    end

    it "delivers an email" do
      expect do
        do_request
      end.to change { all_emails.count }.by +1
    end

    it "delivers an email to given email address" do
      do_request
      expect(last_email_sent).to deliver_to resource.email
    end
  end
end

require "rails_helper"
require "support/shared_examples/requests"
require "factories/password_reset"

describe User::PasswordsController do
  include SpecHelpers::Email
  describe "create" do
    def do_request(**_attributes)
      post :create, format: :jsonapi, passwords: {
        login: user.login
      }
    end

    let(:resource) { build :password_reset, user: user }
    let(:user) { create :user, :registered }

    it_behaves_like :create_resource_request, name: :passwords, persisted: false do
      let(:respond_with) { { email: user.login } }
    end

    it "delivers an email" do
      expect do
        do_request
      end.to change { all_emails.count }.by +1
    end

    it "delivers an email to user email address" do
      do_request
      expect(last_email_sent).to deliver_to user.email
    end
  end
end

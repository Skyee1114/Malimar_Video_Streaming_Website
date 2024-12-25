require "rails_helper"
require "support/shared_examples/requests"
require "support/shared_examples/auth_strategy"
require "factories/user"

describe User::SessionsController do
  let(:user) { create :user, :registered }

  describe "create" do
    def do_request
      post :create, format: :json
    end

    let(:user) { create :user, :with_password, password: "secret" }
    before { sign_in user, basic: "secret" }

    it_behaves_like :create_resource_request, name: :sessions, persisted: false do
      let(:respond_with) do
        { id: anything }
      end
    end

    describe "when login failed" do
      let(:user) { build :user }
      it_behaves_like :unauthorized
    end

    describe "basic" do
      describe "when basic credentials provided" do
        let(:auth_param) { ActionController::HttpAuthentication::Basic.encode_credentials(user.email, user.password).sub /^Basic /, "" }
        it_behaves_like :auth_strategy, type: "Basic", group: :with_password
      end
    end

    describe "facebook" do
      let(:user) { build :user, :facebook, email: "alexander.n.paramonov@gmail.com" }
      before do
        WebMock.stub_request(:get, /.*access_token=abc.*/)
               .to_return body: read_fixture("requests/facebook/user_details.json")

        WebMock.stub_request(:get, /.*access_token=invalid.*/)
               .to_return body: read_fixture("requests/facebook/invalid_token.json")
      end

      let(:auth_param) { "abc" }
      it_behaves_like :auth_strategy, type: "Facebook", group: :facebook do
        let(:user_attributes) { { email: "alexander.n.paramonov@gmail.com" } }
        before { sign_in nil, auth_header: auth_header }

        it "creates local account" do
          expect do
            do_request
          end.to change { User::Local.count }.by +1
        end

        it "creates local account once" do
          do_request
          expect do
            do_request
          end.not_to change { User::Local.count }
        end
      end
    end

    describe "google" do
      let(:user) { build :user, :google, email: "alexander.n.paramonov@gmail.com" }

      let(:auth_param) { "abc" }
      it_behaves_like :auth_strategy, type: "Google", group: :google do
        let(:user_attributes) { { email: "alexander.n.paramonov@gmail.com" } }
        before { sign_in nil, auth_header: auth_header }
        before do
          allow_any_instance_of(Authentication::GoogleStrategy).to receive(:get_user_info_from_token).with("abc").and_return payload
          allow_any_instance_of(Authentication::GoogleStrategy).to receive(:get_user_info_from_token).with("invalid").and_raise(Google::Auth::IDTokens::VerificationError.new("bla"))
        end
        let(:payload) { {
          "email"=>"alexander.n.paramonov@gmail.com",
        } }

        it "creates local account" do
          expect do
            do_request
          end.to change { User::Local.count }.by +1
        end

        it "creates local account once" do
          do_request
          expect do
            do_request
          end.not_to change { User::Local.count }
        end
      end
    end
  end
end

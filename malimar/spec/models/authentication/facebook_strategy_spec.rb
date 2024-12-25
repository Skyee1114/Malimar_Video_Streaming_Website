require "rails_helper"
require "support/spec_helpers/fixtures"
require "factories/user"
require_relative "bearer_strategy_specs"

module Authentication
  describe FacebookStrategy do
    include SpecHelpers::Fixtures

    subject { described_class.new request }
    let!(:request) { double :request, authorization: "Facebook #{token}" }
    let(:token) { "abc" }

    it_behaves_like :bearer_strategy do
      let(:token_name) { "Facebook" }
    end

    it "sets the secret for the client" do
      user = build :user, :facebook
      expect(Koala::Facebook::API).to receive(:new).with(anything, "foo").and_return double(get_object: { "email" => user.email })
      strategy = described_class.new request, secret: "foo"
      strategy.authenticate
    end

    describe "#authenticate" do
      let(:user) { build :user, :facebook, email: "alexander.n.paramonov@gmail.com" }

      before do
        WebMock.stub_request(:get, /access_token=abc/)
               .to_return(body: read_fixture("requests/facebook/user_details.json"))
      end

      it "returns the user" do
        loaded_user = subject.authenticate
        expect(loaded_user).to eq user
      end

      it "returns registered user" do
        loaded_user = subject.authenticate
        expect(loaded_user).to be_registered
      end

      it "creates local account" do
        expect do
          loaded_user = subject.authenticate
          expect(loaded_user).to be_local
          expect(loaded_user).to eq user
        end.to change { User::Local.count }.by +1
      end

      it "creates local account once" do
        subject.authenticate
        expect do
          loaded_user = subject.authenticate
          expect(loaded_user).to be_local
          expect(loaded_user).to eq user
        end.not_to change { User::Local.count }
      end

      describe "when policy does not allow local account creation" do
        it "raises the NotAuthorizedError" do
          allow_any_instance_of(User::LocalPolicy).to receive(:create?).and_return false
          expect do
            subject.authenticate
          end.to raise_error(Pundit::NotAuthorizedError)
        end
      end

      describe "on Koala::Facebook::APIError" do
        before { allow(subject).to receive(:get_client).with(any_args).and_raise(Koala::Facebook::APIError.new(401, "")) }

        it "raises Authentication::Error" do
          expect do
            subject.authenticate
          end.to raise_error(Authentication::Error)
        end
      end

      describe "when user did not allow to get his email" do
        before { allow(subject).to receive(:get_client).with(any_args).and_return client }
        let(:client) { double :client, get_object: {} }

        it "raises Authentication::Error" do
          expect do
            subject.authenticate
          end.to raise_error(Authentication::Error)
        end
      end

      describe "when user is invalid" do
        before { allow(subject).to receive(:get_client).with(any_args).and_return client }
        let(:client) { double :client, get_object: { "email" => user.email } }
        let(:user) { build :user, :facebook, :invalid }

        it "raises Authentication::Error" do
          expect do
            subject.authenticate
          end.to raise_error(Authentication::Error)
        end
      end
    end
  end
end

require "rails_helper"
require "support/spec_helpers/fixtures"
require "factories/user"
require_relative "bearer_strategy_specs"
require "support/vcr"

module Authentication
  describe GoogleStrategy do
    include SpecHelpers::Fixtures

    subject { described_class.new request, client_id: client_id }
    let!(:request) { double :request, authorization: "Google #{token}" }
    let(:token) { "abc" }
    let(:client_id) { "google client id" }

    it_behaves_like :bearer_strategy do
      let(:token_name) { "Google" }
    end

    describe "#authenticate" do
      let(:user) { build :user, :google, email: "alexander.n.paramonov@gmail.com" }

      before { allow(subject).to receive(:get_user_info_from_token).with(any_args).and_return payload }
      let(:payload) { {
        "iss"=>"https://accounts.google.com",
        "nbf"=>1641741091,
        "aud"=>client_id,
        "sub"=>"113668799676561978514",
        "email"=>"alexander.n.paramonov@gmail.com",
        "email_verified"=>true,
        "azp"=>client_id,
        "name"=>"Alexander Paramonov",
        "picture"=>"https://lh3.googleusercontent.com/a/bla",
        "given_name"=>"Alexander",
        "family_name"=>"Paramonov",
        "iat"=>1641741391,
        "exp"=>1641744991,
        "jti"=>"254ee55dfabe54be2b6d67d4388561c66aef8bf0"
      } }

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

      describe "on Google::Auth::IDTokens::VerificationError" do
        before { allow(subject).to receive(:get_user_info_from_token).with(any_args).and_raise(Google::Auth::IDTokens::VerificationError.new("testerror")) }

        it "raises Authentication::Error" do
          expect do
            subject.authenticate
          end.to raise_error(Authentication::Error)
        end
      end

      describe "when user did not allow to get his email" do
        let(:payload) { {} }

        it "raises Authentication::Error" do
          expect do
            subject.authenticate
          end.to raise_error(Authentication::Error)
        end
      end

      describe "when user is invalid" do
        let(:payload) { { "email" => user.email } }
        let(:user) { build :user, :google, :invalid }

        it "raises Authentication::Error" do
          expect do
            subject.authenticate
          end.to raise_error(Authentication::Error)
        end
      end
    end
  end
end

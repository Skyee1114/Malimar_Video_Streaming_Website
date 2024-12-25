require "rails_helper"
require "factories/user"

module Authentication
  describe LoginStrategy do
    subject { described_class.new request }
    let!(:request) { double :request, authorization: credentials }
    let(:credentials) { ActionController::HttpAuthentication::Basic.encode_credentials user.email, user.password }

    let(:user) { build_stubbed :user, :with_password }

    describe "#valid?" do
      specify "when login or password present" do
        expect(subject).to be_valid
      end
    end

    describe "#authenticate" do
      let(:user) { create :user, :with_password }

      it "returns the user" do
        expect(subject.authenticate).to eq user
      end

      describe "when invalid credentials provided" do
        let(:user) { build_stubbed :user, :with_password }

        it "raises Authentication::Error" do
          expect do
            subject.authenticate
          end.to raise_error(Authentication::Error)
        end
      end

      describe "when try to sign is as user without password" do
        let(:user) { create :user, :registered }
        let(:credentials) { ActionController::HttpAuthentication::Basic.encode_credentials user.email, "something" }

        it "raises Authentication::Error" do
          expect do
            subject.authenticate
          end.to raise_error(Authentication::Error)
        end
      end

      describe "when no credentials provided" do
        let(:user) { build_stubbed :user, :with_password, email: "", password: "" }

        it "does not hit the database" do
          expect(User).not_to receive(:where)

          expect do
            subject.authenticate
          end.to raise_error(Authentication::Error)
        end

        it "raises Authentication::Error" do
          expect do
            subject.authenticate
          end.to raise_error(Authentication::Error)
        end
      end
    end
  end
end

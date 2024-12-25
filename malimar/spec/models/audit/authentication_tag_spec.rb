require "support/stub_ar"
require "models/audit/authentication_tag"
require "action_controller/http_authentication/basic"

module Audit
  describe AuthenticationTag do
    let(:audit_auth_tag) { described_class.new encoder_key: "key" }

    describe "#call" do
      subject { audit_auth_tag.call request }

      let(:tokenizer) { Tokenizer.new encoder_key: "key" }
      let(:token) { tokenizer.generate_token user }
      let(:user) { double :user, id: "123", login: "hello", email: "hello@example.com", origin: "local", subscription: spy }

      describe "Bearer token" do
        let(:request) { double :request, authorization: "Bearer #{token}" }

        it "returns user login" do
          is_expected.to eq "hello"
        end

        context "when token is invalid" do
          let(:token) { "invalid" }

          it { is_expected.to eq described_class::INVALID }
        end

        context "when no token provided" do
          let(:token) { "" }

          it { is_expected.to eq described_class::ANONYM }
        end
      end

      describe "No header" do
        let(:request) { double :request, authorization: nil }

        it { is_expected.to eq described_class::ANONYM }
      end

      describe "Basic auth" do
        let(:request) { double :request, authorization: credentials }
        let(:credentials) { ActionController::HttpAuthentication::Basic.encode_credentials login, "password" }
        let(:login) { "hello@example.com" }

        it { is_expected.to eq described_class::ANONYM }

        context "when no credentials provided" do
          let(:credentials) { "" }

          it { is_expected.to eq described_class::ANONYM }
        end
      end
    end

    describe "employee_login?" do
      subject { audit_auth_tag.employee_login?(login) }

      context "for @malimar.tv" do
        let(:login) { "test@malimar.tv" }

        specify { is_expected.to be false }
      end

      context "for @another.com" do
        let(:login) { "test@another.com" }

        specify { is_expected.to be false }
      end

      context "for @malimar.com" do
        let(:login) { "test@malimar.com" }

        specify { is_expected.to be true }
      end

      context "for @malimar.com.whatever" do
        let(:login) { "test@malimar.com.whatever" }

        specify { is_expected.to be false }
      end
    end
  end
end

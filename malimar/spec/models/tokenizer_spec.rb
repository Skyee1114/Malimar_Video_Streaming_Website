require "support/stub_ar"
require "models/tokenizer"
require "support/wisper"

# FIXME: use factories
describe Tokenizer do
  subject { described_class.new encoder_key: "key" }
  let(:user) { double :user, id: "hello", email: "hello@example.com", login: "hello@example.com", origin: :local, subscription: spy }
  before { allow(User::Local).to receive(:find).with("hello").and_return user }

  describe "#generate_token" do
    it "returns a token for given user" do
      token = subject.generate_token user
      encoder = subject.send :encoder

      expect(encoder.decode(token)).to include user: include(
        "origin" => "local",
        "login" => user.login,
        "id" => user.id
      )
    end

    it "supports reverse operation" do
      token = subject.generate_token user
      loaded_user = subject.load_user token
      expect(loaded_user).to have_attributes id: user.id
    end

    describe "when user not provided" do
      it "raises ArgumentError" do
        expect do
          subject.generate_token nil
        end.to raise_error ArgumentError
      end
    end

    describe "when additional encoder options provided" do
      let(:options) { { expires_in: 5 } }
      let(:encoder) { subject.send :encoder }

      it "sends them to encoder" do
        expect(encoder).to receive(:encode).with anything, hash_including(options)
        subject.generate_token user, **options
      end
    end

    it "emits a token_issued event" do
      expect { subject.generate_token user }.to broadcast :token_issued
    end
  end

  describe "#load_user" do
    let(:token) { subject.generate_token user }

    it "loads the user from token payload" do
      loaded_user = subject.load_user token
      expect(loaded_user).to have_attributes id: user.id
    end

    describe "when invited token provided" do
      let(:user) { double :user, id: "hello", email: "hello@example.com", login: "hello@example.com", origin: :invited, subscription: spy }
      it "returns invited user" do
        expect(subject.load_user(token)).to be_a User::Invited
      end
    end

    describe "when token is corrupted" do
      let(:token) { "corrupted" }
      it "raises Error" do
        expect do
          subject.load_user token
        end.to raise_error(described_class::Error)
      end
    end

    describe "when token is nil" do
      let(:token) { nil }
      it "raises ArgumentError" do
        expect do
          subject.load_user nil
        end.to raise_error ArgumentError
      end
    end

    describe "when token is empty" do
      let(:token) { "" }
      it "raises Error" do
        expect do
          subject.load_user token
        end.to raise_error(described_class::Error)
      end
    end

    describe "when signature is invalid" do
      let(:token) { described_class.new(encoder_key: "another_key").generate_token user }

      it "raises Error" do
        expect do
          subject.load_user token
        end.to raise_error(described_class::Error)
      end
    end

    describe "when issuer does not match" do
      it "raises Error" do
        token
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("DOMAIN").and_return "another_domain.com"
        expect do
          subject.load_user token
        end.to raise_error(described_class::Error)
      end
    end

    describe "when user can not be found" do
      before { allow(User::Local).to receive(:find).and_raise ActiveRecord::RecordNotFound }

      it "raises Error" do
        expect do
          subject.load_user token
        end.to raise_error(described_class::Error)
      end
    end

    it "emits a user_loaded event" do
      expect { subject.load_user token }.to broadcast :user_loaded
    end
  end
end

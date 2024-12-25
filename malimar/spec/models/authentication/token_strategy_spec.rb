require "support/stub_ar"
require "models/authentication/token_strategy"

# FIXME: use factories
module Authentication
  describe TokenStrategy do
    subject { described_class.new request, encoder_key: "key" }
    let!(:request) { double :request, authorization: "Bearer #{token}" }

    let(:tokenizer) { Tokenizer.new encoder_key: "key" }
    let(:token) { tokenizer.generate_token user }
    let(:user) { double :user, id: "123", login: "hello", email: "hello@example.com", origin: "local", subscription: spy }

    it "sets the encoder_key for tokenizer" do
      expect(Tokenizer).to receive(:new).with(hash_including(encoder_key: "foo")).and_return spy
      strategy = described_class.new request, encoder_key: "foo"
      strategy.authenticate
    end

    describe "#valid?" do
      describe "when bearer header is set" do
        let!(:request) { double :request, authorization: "Bearer something" }

        it "is true" do
          expect(subject).to be_valid
        end
      end

      describe "when bearer header set but is nil" do
        let!(:request) { double :request, authorization: "Bearer" }

        it "is true" do
          expect(subject).to be_valid
        end
      end

      describe "when bearer header set but is empty" do
        let!(:request) { double :request, authorization: "Bearer " }

        it "is true" do
          expect(subject).to be_valid
        end
      end

      describe "when bearer header not set" do
        let!(:request) { double :request, authorization: "something" }

        it "is false" do
          expect(subject).not_to be_valid
        end
      end

      describe "when authorization header not set" do
        let!(:request) { double :request, authorization: nil }

        it "is false" do
          expect(subject).not_to be_valid
        end
      end
    end

    describe "#authenticate" do
      before { allow_any_instance_of(Tokenizer).to receive(:load_user).with(token).and_return user }

      it "returns the user" do
        expect(subject.authenticate).to eq user
      end

      describe "on Tokenizer::Error" do
        before { allow_any_instance_of(Tokenizer).to receive(:load_user).and_raise Tokenizer::Error }

        it "raises Authentication::Error" do
          expect do
            subject.authenticate
          end.to raise_error(Authentication::Error)
        end
      end
    end
  end
end

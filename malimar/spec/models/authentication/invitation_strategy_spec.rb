require "support/stub_ar"
require "models/authentication/invitation_strategy"

# FIXME: use factories
module Authentication
  describe InvitationStrategy do
    subject { described_class.new request, encoder_key: "key" }
    let!(:request) { double :request, params: { token: token } }

    let(:tokenizer) { Tokenizer.new encoder_key: "key" }
    let(:token) { tokenizer.generate_token user }
    let(:user) { double :user, id: "hello", email: "hello@example.com", login: "hello@example.com", origin: "local", subscription: spy }

    it "sets the encoder_key for tokenizer" do
      expect(Tokenizer).to receive(:new).with(hash_including(encoder_key: "foo")).and_return spy
      strategy = described_class.new request, encoder_key: "foo"
      strategy.authenticate
    end

    describe "#valid?" do
      describe "when token param defined" do
        let!(:request) { double :request, params: { token: "some token" } }

        it "is true" do
          expect(subject).to be_valid
        end
      end

      describe "when token param defined but is nil" do
        let!(:request) { double :request, params: { token: nil } }

        it "is true" do
          expect(subject).to be_valid
        end
      end

      describe "when token param defined but is empty" do
        let!(:request) { double :request, params: { token: "" } }

        it "is true" do
          expect(subject).to be_valid
        end
      end

      describe "when token param not defined" do
        let!(:request) { double :request, params: { foo: :bar } }

        it "is false" do
          expect(subject).not_to be_valid
        end
      end

      describe "when params not set" do
        let!(:request) { double :request, params: nil }

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

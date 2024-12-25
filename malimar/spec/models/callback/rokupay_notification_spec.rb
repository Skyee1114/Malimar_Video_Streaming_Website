require "rails_helper"
require "support/wisper"
require "support/spec_helpers/request_counter"
require "factories/user"

describe Callback::RokupayNotification do
  include SpecHelpers::RequestCounter

  subject { described_class.new request }
  let(:request) { double :request, raw_post: URI.encode_www_form(params), params: params }
  let(:params) { { foo: "bar", payer_email: payer_email } }
  let(:payer_email) { user.email }
  let(:uri_params) { URI.encode_www_form params }
  let(:transaction) { spy :transaction }
  let(:user) { create :user }

  before { allow(subject).to receive(:create_transaction).and_return transaction }
  before { allow(subject).to receive(:activate_subscription) }

  describe "#save" do
    before { allow(subject).to receive(:valid?).and_return true }

    it "creates a transaction" do
      expect(subject).to receive(:create_transaction)
      subject.save
    end

    describe "when purchased as a new user" do
      let(:payer_email) { "newuser@example.com" }

      it "creates a local account" do
        expect do
          subject.save
        end.to change { User::Local.count }.by +1
      end
    end

    it "broadcasts an event" do
      expect { subject.save }.to broadcast :successful_transaction, transaction
    end

    describe "when validation failed" do
      before { allow(subject).to receive(:valid?).and_return false }

      it "creates a transaction" do
        expect(subject).to receive(:create_transaction)
        subject.save
      end

      it "does not broadcast an event" do
        expect { subject.save }.not_to broadcast :new_device_subscription_payment, transaction
      end
    end
  end

  describe "#valid?" do
    before :each do
      plan = double :plan, cost: "69.00"
      params.merge! mc_gross: "69.00"
      allow(subject).to receive(:plan).and_return plan
    end

    pending "validates request on Rokupay server" do
      expect do
        subject.valid?
      end.to change { count_requests :post, "https://www.sandbox.paypal.com/cgi-bin/webscr" }.by +1
    end

    describe "when Rokupay validation succeeded" do
      it "is valid" do
        expect(subject).to be_valid
      end

      describe "when purchased incorrect amount" do
        before do
          plan = double :plan, cost: "69.00"
          allow(subject).to receive(:plan).and_return plan
          params.merge! mc_gross: "0.1"
        end

        it "is invalid" do
          expect(subject).not_to be_valid
        end

        it "broadcasts paypal_payment_error" do
          expect { subject.valid? }.to broadcast :rokupay_payment_error, "#{described_class.name}::InvalidAmountError", request.raw_post
        end
      end

      describe "when purchased unexisting plan" do
        before do
          allow(subject).to receive(:plan).and_return nil
        end

        it "is invalid" do
          expect(subject).not_to be_valid
        end

        it "broadcasts paypal_payment_error" do
          expect { subject.valid? }.to broadcast :rokupay_payment_error, "#{described_class.name}::InvalidPlanError", request.raw_post
        end
      end

      describe "when misses required fields" do
        before do
          params.delete :payer_email
        end

        it "is invalid" do
          expect(subject).not_to be_valid
        end

        it "broadcasts paypal_payment_error" do
          expect { subject.valid? }.to broadcast :rokupay_payment_error, "KeyError", "key not found: :payer_email"
        end
      end
    end

    # describe "when PayPal validation failed" do
    #   before :each do
    #     # WebMock.stub_request(:post, "https://www.sandbox.paypal.com/cgi-bin/webscr")
    #     #        .with(body: "cmd=_notify-validate&#{uri_params}")
    #     #        .to_return(status: 200, body: "something", headers: {})
    #   end

    #   pending "is invalid" do
    #     expect(subject).not_to be_valid
    #   end
    # end
  end
end

require "rails_helper"
require "support/wisper"
require "factories/form/subscription_payment"
require "factories/user"
require "factories/device/roku"

describe Form::SubscriptionPayment do
  subject { build :subscription_payment_form, user: user, plan: plan }

  let(:user) { create :user }
  let(:plan) { build :plan, :web }

  describe "on successful payment" do
    before :context do
      WebMock.stub_request(:post, "https://test.authorize.net/gateway/transact.dll")
             .to_return(body: read_fixture("requests/authorize_net/successful_payment.csv"))
    end

    it "emits new_web_subscription_payment event" do
      expect { subject.save }.to broadcast :new_web_subscription_payment
    end

    describe "when user has same billing address" do
      let!(:billing_address) { create :billing_address, user_id: user.id }
      subject { build :subscription_payment_form, user: user, billing_address: billing_address.attributes.except("id", "user_id") }

      it "does not create new billing address" do
        expect do
          subject.save
        end.not_to change { BillingAddress.count }
      end
    end

    describe "when buy a roku plan" do
      subject { build :subscription_payment_form, device: device, plan: plan }

      let(:device) { create :roku_device }
      let(:plan) { build :plan, :roku }

      it "emits new_device_subscription_payment event" do
        expect { subject.save }.to broadcast :new_device_subscription_payment
      end

      describe "null device" do
        let(:device) { nil }

        it "does not emit new_device_subscription_payment event" do
          expect { subject.save }.not_to broadcast :new_device_subscription_payment
        end
      end
    end
  end

  describe "on failed payment" do
    before :context do
      WebMock.stub_request(:post, "https://test.authorize.net/gateway/transact.dll")
             .to_return(body: read_fixture("requests/authorize_net/duplicated_payment.csv"))
    end

    it "returns transaction error" do
      subject.save
      expect(subject.errors).not_to be_empty
      expect(subject.errors[:base]).to include /duplicate/
    end

    it "does not emit an event" do
      expect { subject.save }.not_to broadcast :new_web_subscription_payment
    end

    describe "when buy a roku plan" do
      subject { build :subscription_payment_form, device: device, plan: plan }

      let(:device) { create :roku_device }
      let(:plan) { build :plan, :roku }

      it "does not emit an event" do
        expect { subject.save }.not_to broadcast :new_device_subscription_payment
      end
    end
  end
end

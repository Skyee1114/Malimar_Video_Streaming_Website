require "rails_helper"
require "support/shared_examples/requests"
require "support/shared_examples/exclusively_for_owner"
require "factories/user"
require "factories/device/roku"
require "factories/plan"
require "factories/card"
require "factories/billing_address"
require "aws-sdk"

describe SubscriptionPaymentsController do
  include SpecHelpers::Email

  let(:user) { create :user, :registered }
  before { sign_in user }

  describe "create" do
    def do_request(linked: {})
      post :create, format: :jsonapi, subscription_payments: {
        links: {
          plan: plan.id,
          user: user.id,
          **linked
        },

        card: card.to_hash,
        billing_address: billing_address.to_hash
      }
    end

    before :context do
      WebMock.stub_request(:post, "https://test.authorize.net/gateway/transact.dll")
             .to_return(body: read_fixture("requests/authorize_net/successful_payment.csv"))
    end

    let(:plan) { create :plan }
    let(:card) { build :card }
    let(:billing_address) { build :billing_address }

    it_behaves_like :create_resource_request, name: :subscription_payments, persisted: false

    describe "when card data is invalid" do
      let(:card) { build :card, :invalid }
      it_behaves_like :error_resource, name: :errors do
        let(:respond_with) { { detail: /number/i } }
      end
    end

    describe "when accessed by guest user" do
      before { sign_out }
      it_behaves_like :forbidden
    end

    describe "web plan" do
      let(:plan) { create :plan, :web }
      it_behaves_like :create_resource_request, name: :subscription_payments, persisted: false

      it "allows premium access for user" do
        expect do
          do_request
          user.permissions.reload
        end.to change { user.subscription.has_access_to? :premium }.from(false).to(true)
      end

      it "delivers emails" do
        expect do
          do_request
        end.to change { all_emails.count }.by +1
      end

      it "delivers an email to customer" do
        email = billing_address.email

        do_request
        expect(find_email(email)).to deliver_to email
      end
    end

    describe "roku plan" do
      before :context do
        Aws.config[:access_key_id] = "key"
        Aws.config[:secret_access_key] = "secret"

        WebMock.stub_request(:put, "https://aseaniptv2.s3.us-west-1.amazonaws.com/Roku/SERIAL/4114AC001000")
               .to_return(status: 200, body: "", headers: {})
      end

      def do_request(**linked)
        device_identifier = linked.fetch(:device) { device }
        if device_identifier.respond_to? :id
          device_identifier = {
            serial_number: device_identifier.serial_number,
            type: device_identifier.type
          }
        end

        super linked: { device: device_identifier }
      end

      let(:plan) { create :plan, :roku }
      let(:device) { create :roku_device }
      it_behaves_like :create_resource_request, name: :subscription_payments, persisted: false

      it "allows premium access for device" do
        expect do
          do_request
          device.permissions.reload
        end.to change { device.subscription.has_access_to? :premium }.from(false).to(true)
      end

      it "delivers emails" do
        expect do
          do_request
        end.to change { all_emails.count }.by +2
      end

      it "creates new device" do
        expect do
          do_request
        end.to change { Device.count }.by +1
      end

      describe "when device with same serial exists" do
        let!(:another_device) { create :roku_device }
        let(:device) { build :roku_device, serial_number: another_device.serial_number }

        it "does not create new device" do
          expect do
            do_request
          end.not_to change { Device.count }
        end
      end

      describe "when use invalid device serial_number" do
        let(:device) { build :roku_device, :invalid }

        it "responds with 422" do
          expect(do_request).to have_http_status :unprocessable_entity
        end
      end

      describe "when no roku provided" do
        it "does not create new device" do
          expect do
            do_request device: nil
          end.not_to change { Device.count }

          expect do
            do_request device: ""
          end.not_to change { Device.count }
        end

        it "does not add new permissions" do
          expect do
            do_request device: nil
          end.not_to change { Permission.count }

          expect do
            do_request device: ""
          end.not_to change { Permission.count }
        end
      end

      it "delivers an email to customer" do
        email = billing_address.email

        do_request
        expect(find_email(email)).to deliver_to email
      end

      describe "email to support" do
        let(:email) { ENV["ROKU_ACTIVATION_EMAIL_RECEIVER"] }

        it "delivers an email to support" do
          do_request
          expect(support_email).to deliver_to email
        end

        it "includes user ip in email" do
          do_request
          expect(support_email).to have_body_text /0\.0\.0\.0|127\.0\.0\.1/
        end

        it "attaches roku serial file" do
          do_request
          expect(support_email.attachments).not_to be_empty
        end

        private

        def support_email
          find_email email
        end
      end

      describe "s3 integration" do
        it "uploads file to s3" do
          expect do
            do_request
          end.to change { count_requests :put, "https://aseaniptv2.s3.us-west-1.amazonaws.com/Roku/SERIAL/#{device.serial_number}" }.by +1
        end
      end
    end

    describe "mixed plan" do
      def do_request(**linked)
        device_identifier = linked.fetch(:device) { device }
        if device_identifier.respond_to? :id
          device_identifier = {
            serial_number: device_identifier.serial_number,
            type: device_identifier.type
          }
        end

        super linked: { device: device_identifier }
      end

      let(:plan) { create :plan, :roku, :web }
      let(:device) { create :roku_device }

      it "reverts both subscriptions if later one fails" do
        allow_any_instance_of(Device).to receive(:subscription).and_raise

        expect do
          do_request
        end.to raise_error(RuntimeError)

        user.permissions.reload
        expect(user.subscription).not_to have_access_to :premium
      end
    end
  end
end

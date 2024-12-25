require "rails_helper"
require "aws-sdk"
require "factories/plan"
require "factories/user"

describe Callback::RokupayNotificationsController do
  include SpecHelpers::Email
  before :context do
    Aws.config[:access_key_id] = "key"
    Aws.config[:secret_access_key] = "secret"

    WebMock.stub_request(:put, "https://aseaniptv2.s3.us-west-1.amazonaws.com/Roku/SERIAL/4114AC001000")
           .to_return(status: 200, body: "", headers: {})
  end

  def do_request(params)
    post :create, params
  end

  def do_request(linked: {})
    post :create, format: :jsonapi, rokupay_notifications: {
      links: {
        plan: plan.id,
        billing_address: billing_address.to_hash
        **linked
      },
    }
  end

  let(:billing_address) { build :billing_address }

  before do
    # allow(PayPal::SDK::Core::API::IPN).to receive(:valid?).and_return true
  end

  let(:serial_number) { "4114AC001000" }
  let(:type) { "Device::Roku" }
  let(:plan) { create :plan, :web, :roku }

  describe "when user exists" do
    let(:user) { create :user }
    let(:email) { user.email }
    let(:valid_message_params) { Rack::Utils.parse_nested_query("auth_id=123&contact_phone=123&serial_number=#{serial_number}&device_type=#{type}&payer_email=#{email}&plan_id=#{plan.id}&mc_gross=#{plan.cost}&residence_country=US&verify_sign=AFcWxV21C7fd0v3bYYYRCpSSRl31AXi5tzp0u2U-8QDyy.oC2A1Dhx04&address_country=United+States&address_city=San+Jose&first_name=John&mc_currency=USD&payment_date=01%3A48%3A31+Dec+04%2C+2012+PST&address_country_code=US&payment_gross=1.00&address_zip=95131&address_state=CA&address_name=John+Doe&last_name=Doe&address_street=1+Main+St").symbolize_keys }
    let(:invalid_message_params) { { "invalid" => "invalid" } }

    it "responds with ok" do
      do_request valid_message_params
      assert_response :ok
    end

    describe "on valid message" do
      def do_request(**params)
        super valid_message_params.merge(params)
      end

      it "creates new transaction" do
        expect do
          do_request
        end.to change { Transaction.count }.by +1
      end

      it "delivers emails" do
        expect do
          do_request
        end.to change { all_emails.count }
      end

      it "delivers an email to customer" do
        do_request payer_email: email
        expect(find_email(email)).to deliver_to email
      end

      describe "email to support" do
        let(:email_receiver) { ENV["ROKU_ACTIVATION_EMAIL_RECEIVER"] }

        it "delivers an email to support" do
          do_request
          expect(support_email).to deliver_to email_receiver
        end

        it "attaches roku serial file" do
          do_request
          expect(support_email.attachments).not_to be_empty
        end

        private

        def support_email
          find_email email_receiver
        end
      end

      describe "s3 integration" do
        it "uploads file to s3" do
          expect do
            do_request
          end.to change { count_requests :put, "https://aseaniptv2.s3.us-west-1.amazonaws.com/Roku/SERIAL/#{serial_number}" }.by +1
        end
      end

      shared_examples :rokupay_no_serial_number do
        it "creates new transaction" do
          expect do
            do_request
          end.to change { Transaction.count }.by +1
        end

        it "delivers an email to customer" do
          do_request payer_email: email
          expect(find_email(email)).to deliver_to email
        end

        describe "email to support" do
          let(:email_receiver) { ENV["ROKU_ACTIVATION_EMAIL_RECEIVER"] }

          it "does not deliver an email to support" do
            expect do
              do_request
            end.to change { all_emails.count }.by +1 # but not +2
          end
        end
      end

      describe "without serial number" do
        let(:serial_number) { "" }
        it_behaves_like :rokupay_no_serial_number
      end

      describe "with N/A as serial number" do
        let(:serial_number) { "N/A" }
        it_behaves_like :rokupay_no_serial_number
      end

      describe "with invalid as serial number" do
        let(:serial_number) { "a$v" }

        it "responds with ok" do
          expect(do_request).to have_http_status :ok
        end

        it "notifies Rollbar" do
          expect_any_instance_of(Rollbar::Notifier).to receive(:error)
          do_request
        end
      end
    end

    describe "on invalid payment" do
      let(:support_email) { ENV["ROKU_ACTIVATION_EMAIL_RECEIVER"] }

      def do_request(**_params)
        super valid_message_params.merge mc_gross: 0.10
      end

      it "creates a transaction" do
        expect do
          do_request
        end.to change { Transaction.count }.by +1
      end

      it "delivers emails" do
        expect do
          do_request
        end.to change { all_emails.count }.by +1
      end

      it "delivers an email to support" do
        do_request
        expect(last_email_sent).to deliver_to support_email
      end

      it "notifies Rollbar" do
        expect_any_instance_of(Rollbar::Notifier).to receive(:error)
        do_request
      end

      it "respons with ok" do
        expect do
          do_request
        end.not_to raise_error
        expect(response).to be_ok
      end
    end
  end
end

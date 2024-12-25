require "rails_helper"
require "paypal-sdk-core"
require "aws-sdk"
require "factories/plan"
require "factories/user"

describe Callback::PaymentNotificationsController do
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

  before do
    allow(PayPal::SDK::Core::API::IPN).to receive(:valid?).and_return true
  end

  let(:email) { "test@example.com" }
  let(:serial_number) { "4114AC001000" }
  let(:type) { "Device::Roku" }
  let(:plan) { create :plan, :web, :roku }
  let(:user) { create :user }
  let(:valid_message_params) { Rack::Utils.parse_nested_query("auth_id=123&contact_phone=123&option_selection1=#{serial_number}&option_selection2=#{user.id}&option_selection3=#{type}&payer_email=#{email}&item_number=#{plan.id}&mc_gross=#{plan.cost}&residence_country=US&verify_sign=AFcWxV21C7fd0v3bYYYRCpSSRl31AXi5tzp0u2U-8QDyy.oC2A1Dhx04&address_country=United+States&address_city=San+Jose&address_status=unconfirmed&business=platfo_1255077030_biz%40gmail.com&payment_status=Pending&transaction_subject=&protection_eligibility=Ineligible&shipping=0.00&payer_id=934EKX9W68RRU&first_name=John&mc_fee=0.38&txn_id=5AL16697HX185734U&quantity=1&receiver_email=platfo_1255077030_biz%40gmail.com&notify_version=3.7&txn_type=web_accept&payer_status=unverified&mc_currency=USD&test_ipn=1&custom=&payment_date=01%3A48%3A31+Dec+04%2C+2012+PST&payment_fee=0.38&charset=windows-1252&address_country_code=US&payment_gross=1.00&address_zip=95131&ipn_track_id=af0f53159f21e&address_state=CA&receipt_id=4050-1771-4106-3070&pending_reason=paymentreview&tax=0.00&handling_amount=0.00&item_name=&address_name=John+Doe&last_name=Doe&payment_type=instant&receiver_id=HZH2W8NPXUE5W&address_street=1+Main+St").symbolize_keys }
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

    shared_examples :pp_no_serial_number do
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
      it_behaves_like :pp_no_serial_number
    end

    describe "with N/A as serial number" do
      let(:serial_number) { "N/A" }
      it_behaves_like :pp_no_serial_number
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

require "acceptance_helper"
require "factories/user"
require "factories/plan"
require "factories/billing_address"
require "factories/device/roku"

resource "Subscription Payments" do
  include SpecHelpers::Email
  include_context :api

  before :context do
    WebMock.stub_request(:post, "https://test.authorize.net/gateway/transact.dll")
           .to_return(body: read_fixture("requests/authorize_net/successful_payment.csv"))
  end

  module ResponseFields
    def self.included(example)
      example.with_options scope: :subscription_payments do
        # response_field :id,           "Subscription payment id"
        response_field :amount, "Subscription payment amount"
        # response_field :description,  "Subscription payment description"
        # response_field :status,       "Subscription payment status"
      end
    end
  end

  module ParameterFields
    def self.included(example)
      example.with_options scope: :subscription_payments do
        parameter :card,             "Card data"
        parameter :billing_address,  "Billing address, phone and email"
        parameter :invoice,          "Invoice number (optional)"
        parameter :links,            "Linked objects"
      end

      example.let(:card) do
        {
          cvv: 123,
          number: "4111111111111111",
          expiry_month: 12,
          expiry_year: 3000
        }
      end
      example.let(:billing_address) do
        {
          first_name: "Tomas",
          last_name: "Buyer",
          email: "billme@example.com",
          phone: "+1 111 1111 1111",

          address: "Main str",
          city: "Hope",
          state: "DE",
          zip: "1234",
          country: "US"
        }
      end

      example.let(:links) do
        {
          plan: plan.id,
          user: user.id,
          device: {
            serial_number: device.try(:serial_number),
            type: device.try(:type)
          }
        }
      end
      example.let(:user) { api_user }
      example.let(:plan) { create :plan, :web, :one_month }
      example.let(:device) { nil }
    end
  end

  post "/subscription_payments" do
    parameter :subscription_payments, "Subscription resource object"
    include ParameterFields

    response_field :subscription_payments, "Subscription object"
    # response_field :href,                   "Link to subscription payment",  scope: :subscription_payments
    include ResponseFields

    it_behaves_like :authentication_required
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :subscription_payments

    example_request "Pay for subscription" do
      expect(status).to eq 201
    end

    describe "when validation error occurs", response_fields: [] do
      include_context :error

      let(:billing_address) { build(:billing_address, :invalid).to_hash }
      example_request "Payment with invalid email"
    end

    describe "Roku payment" do
      before :context do
        Aws.config[:access_key_id] = "key"
        Aws.config[:secret_access_key] = "secret"

        WebMock.stub_request(:put, "https://aseaniptv2.s3.us-west-1.amazonaws.com/Roku/SERIAL/4114AC001000")
               .to_return(status: 200, body: "", headers: {})
      end

      let(:device) { create :roku_device }
      let(:plan) { create :plan, :roku }

      example "Pay for roku subscription" do
        expect do
          do_request
        end.to change { all_emails.count }.by +2
      end
    end
  end

  post "/subscription_payments?include=plan" do
    parameter :subscription_payments, "Subscription resource object"
    include ParameterFields

    response_field :subscription_payments,  "Subscription object"
    response_field :links,                  "Embedded resources", scope: :subscription_payments
    include ResponseFields

    it_behaves_like :authentication_required
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :subscription_payments

    example_request "Create subscription payment and return plan" do
      expect(json_response[:subscription_payments]).to include links: have_key(:plan)
    end
  end
end

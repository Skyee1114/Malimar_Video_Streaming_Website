require "acceptance_helper"
require "aws-sdk"
require "factories/user"
require "factories/plan"
require "factories/device/roku"

resource "Rokupay notifications" do
  include SpecHelpers::Email
  include_context :api

  before :context do
    Aws.config[:access_key_id] = "key"
    Aws.config[:secret_access_key] = "secret"

    WebMock.stub_request(:put, "https://aseaniptv2.s3.us-west-1.amazonaws.com/Roku/SERIAL/4114AC001000")
           .to_return(status: 200, body: "", headers: {})
  end

  module ResponseFields
    def self.included(example)
      example.with_options scope: :rokupay_notifications do
        response_field :plan, "Applied plan description"
      end
    end
  end

  module ParameterFields
    def self.included(example)
      example.with_options scope: :rokupay_notifications do
        parameter :amount,              "Amount paid"
        parameter :description,         "Transaction description",   required: false
        parameter :transaction_id,      "Transaction id"
        parameter :authorization_code,  "Authorization code"
        parameter :response,            "Transaction response",      required: false
        parameter :invoice,             "Invoice number",            required: false
        parameter :links,               "Linked objects"
      end

      example.let(:amount) { plan.cost }
      example.let(:description) { "1 Month" }
      example.let(:transaction_id) { "8UH417299T4422516" }
      example.let(:authorization_code) { "ABCD" }
      example.let(:response) { "Completed" }

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
      example.let(:invoice) { "ABCD123" }
      example.let(:links) do
        {
          device: {
            serial_number: device.serial_number,
            type: device.type
          },
          billing_address: billing_address,
          plan: plan.id,
          user: {
            email: "tomas@example.com"
          }
        }
      end

      example.let(:plan) { create :plan, :web, :roku, :one_month }
      example.let(:device) { build :roku_device }
    end
  end

  post "/callback/rokupay_notifications" do
    parameter :rokupay_notifications, "Notification request object"
    include ParameterFields

    response_field :rokupay_notifications, "Notification request object"
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :rokupay_notifications

    example "Rokupay notification creates user account and subscribtion" do
      expect do
        do_request
      end.to change { User::Local.count }.by +1

      expect do
        do_request
      end.to change { all_emails.count }.by +3
    end

    describe "when validation error occurs", response_fields: [] do
      include_context :error

      let(:device) { build(:roku_device, :invalid) }
      example "Rokupay notification with invalid device serial" do
        expect do
          do_request
        end.not_to change { User::Local.count }
      end
    end
  end
end

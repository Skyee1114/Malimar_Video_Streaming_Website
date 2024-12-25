require "acceptance_helper"
require "aws-sdk"
require "factories/user"
require "factories/device/activation_request"

resource "Device activation requests" do
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
      example.with_options scope: :activation_requests do
        response_field :first_name,  "Person name"
        response_field :last_name,   "Person name"
        response_field :email,       "Contact email"
        response_field :service,     "Service type"
        response_field :links,       "Embedded resources"
      end
    end
  end

  module ParameterFields
    def self.included(example)
      example.with_options scope: :activation_requests do
        parameter :first_name,  "Person name"
        parameter :last_name,   "Person name"

        parameter :email,       "Contact email"
        parameter :phone,       "Contact phone number"

        parameter :address,     "Street address"
        parameter :city,        "City"
        parameter :state,       "State"
        parameter :zip,         "Postal code"
        parameter :country,     "Country code"

        parameter :referral,    "Referal"
        parameter :service,     "Service type"
        parameter :links,       "Linked objects"
      end

      example.let(:first_name) { activation.first_name }
      example.let(:last_name)  { activation.last_name }

      example.let(:email) { activation.email }
      example.let(:phone) { activation.phone }

      example.let(:address) { activation.address }
      example.let(:city)    { activation.city }
      example.let(:state)   { activation.state }
      example.let(:zip)     { activation.zip }
      example.let(:country) { activation.country }

      example.let(:referral)      { activation.referral }
      example.let(:service)       { activation.service }
      example.let(:links) { { device: activation.device.to_hash } }
    end
  end

  post "/device/activation_requests?include=device" do
    parameter :activation_requests, "Activation request object"
    include ParameterFields

    let(:activation) { build :device_activation_request }

    response_field :activation_requests, "Activation request object"
    include ResponseFields

    it_behaves_like :authentication_required
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :activation_requests

    example "Create new activation request and send the emails" do
      expect do
        do_request
      end.to change { all_emails.count }.by +2
    end

    describe "when validation error occurs", response_fields: [] do
      include_context :error

      let(:links) { { device: build(:roku_device, :invalid).to_hash } }
      example_request "Create activation with invalid email"
    end
  end
end

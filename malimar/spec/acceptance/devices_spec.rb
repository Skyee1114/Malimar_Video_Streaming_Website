require "acceptance_helper"
require "factories/user"
require "factories/device/roku"

resource "Devices" do
  include_context :api

  module ResponseFields
    def self.included(example)
      example.with_options scope: :devices do
        response_field :id,             "Device id"
        response_field :name,           "Device name"
        response_field :type,           "Device type"
        response_field :serial_number,  "Device serial number"
      end
    end
  end

  module ParameterFields
    def self.included(example)
      example.parameter :name,           "Device name",           scope: :devices
      example.parameter :type,           "Device type",           scope: :devices
      example.parameter :serial_number,  "Device serial number",  scope: :devices
      example.parameter :links,          "Links",                 scope: :devices

      example.let(:name) { "Home TV" }
      example.let(:type) { "Device::Roku" }
      example.let(:serial_number) { "123456789012" }
      example.let(:links) do
        {
          user: api_user.id
        }
      end
    end
  end

  get "/devices?user=:user_id" do
    let!(:device) { create :roku_device, user: api_user }
    let(:user_id) { api_user.id }

    response_field :devices, "List of devices"
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_collection, name: :devices
    example_request "Get a list of devices for user" do
      expect(json_response[:devices]).to include include(
        id: device.id
      )
    end
  end

  post "/devices" do
    parameter :devices, "Device resource object"
    include ParameterFields

    response_field :devices, "Device resource object"
    include ResponseFields

    it_behaves_like :authentication_required
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :devices

    example "Add new Device" do
      expect do
        do_request
      end.to change { Device.count }.by +1
    end

    describe "when validation error occurs", response_fields: [] do
      include_context :error

      let(:serial_number) { "ABC" }
      example_request "Validation error"
    end
  end

  get "/devices/:id" do
    include_context :api

    parameter :id,  "Device id"
    let(:id) { device.id }
    let(:device) { create :roku_device, user: api_user }

    response_field :devices, "Device resource object"
    include ResponseFields

    it_behaves_like :authentication_required
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :devices
    example_request "Get device details" do
      expect(json_response[:devices]).to include(
        name: device.name,
        id: device.id
      )
    end
  end

  # put "/devices/:id" do
  #   include_context :api

  #   let!(:user) { create :user }
  #   let(:api_user) { user }

  #   parameter :id,  "User id"
  #   let(:id) { user.id }

  #   parameter :devices, "User resource object"

  #   parameter :email,     "New user contact email",  scope: :devices
  #   parameter :password,  "New user password",       scope: :devices

  #   let(:email) { "alice@example.com" }
  #   let(:password) { "secret123456" }

  #   response_field :devices,  "User resource object"
  #   include ResponseFields

  #   it_behaves_like :authentication_required
  #   it_behaves_like :json_compatible
  #   it_behaves_like :json_api_resource, name: :devices
  #   example_request "Update user details" do
  #     expect(json_response[:devices]).to include(
  #       email: email,
  #       id: user.id
  #     )
  #   end
  # end
end

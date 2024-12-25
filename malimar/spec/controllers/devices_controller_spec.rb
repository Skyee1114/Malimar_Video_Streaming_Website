require "rails_helper"
require "factories/user"
require "factories/device/roku"
require "support/shared_examples/requests"

describe DevicesController do
  let(:resource) { create :roku_device, user: user }
  let(:user) { create :user, :registered }
  before { sign_in user }

  describe "index" do
    def do_request(**params)
      get :index, {
        format: :json,
        user: user.id
      }.merge(params)
    end

    it_behaves_like :get_collection_request, name: :devices
  end

  describe "create" do
    def do_request(**_attributes)
      post :create, format: :jsonapi, devices: {
        name: resource.name,
        serial_number: resource.serial_number,
        type: resource.type,
        links: {
          user: user.id
        }
      }
    end

    let(:resource) { build :roku_device, user: user }

    it_behaves_like :create_resource_request, name: :devices, persisted: false do
      let(:respond_with) { { serial_number: resource.serial_number } }
    end
  end

  describe "show" do
    def do_request(**params)
      get :show, {
        format: :json,
        id: resource.id
      }.merge(params)
    end

    it_behaves_like :get_resource_request, name: :devices

    describe "when resource not found" do
      def do_request
        super id: "not_found"
      end

      it_behaves_like :not_found
    end
  end
end

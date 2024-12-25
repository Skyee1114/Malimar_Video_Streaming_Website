require "rails_helper"
require "factories/user"
require "support/shared_examples/requests"

describe PermissionsController do
  let(:permission) { create :permission, subject: user }
  let(:user) { create :user, :registered }
  before { sign_in user }

  describe "index" do
    def do_request(**params)
      get :index, {
        format: :json,
        user: user_id
      }.merge(params)
    end

    let(:user_id) { user.id }
    let(:resource) { permission }
    it_behaves_like :get_collection_request, name: :permissions

    describe "'active' filter" do
      def do_request
        super filter: { active: true }
      end

      let(:active_permission) { create :permission, subject: user }
      let(:expired_permission) { create :permission, :expired, subject: user }

      it "returns active permissions" do
        active_permission
        do_request
        expect(json_response[:permissions]).to include include id: active_permission.id
      end

      it "does not return expired permissions" do
        expired_permission
        do_request
        expect(json_response[:permissions]).not_to include include id: expired_permission.id
      end
    end
  end
end

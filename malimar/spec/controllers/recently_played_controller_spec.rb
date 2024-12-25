require "rails_helper"
require "factories/user"
require "factories/resource/video"
require "support/shared_examples/requests"

describe RecentlyPlayedController do
  let(:resource) { build :channel, :recently_played, user: user }
  let(:user) { create :user, :registered }
  before { sign_in user }

  describe "index" do
    def do_request(**params)
      get :index, { format: :jsonapi }.merge(params)
    end

    it_behaves_like :get_collection_request, name: :recently_played
  end

  describe "destroy" do
    def do_request(**_attributes)
      delete :destroy, { format: :jsonapi, id: resource.id }
    end

    it_behaves_like :delete_resource_request, name: :recently_played
  end
end

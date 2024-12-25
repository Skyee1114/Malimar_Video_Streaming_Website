require "rails_helper"
require "support/shared_examples/requests"
require "support/vcr"
require "factories/user"
require "factories/resource/video"
require "factories/resource/container"

describe Resource::EpisodesController do
  include SpecHelpers::VcrDoRequest[:episodes]
  let(:resource) { build :episode, :animals_21 }
  let(:show_id) { build(:show, :animals).id }

  before(:context) { @user = create :user, :premium }
  before(:each) { sign_in @user }

  describe "show" do
    def do_request(**params)
      super do
        get :show, {
          format: :json,
          id: resource.id,
          show: show_id
        }.merge(params)
      end
    end

    it_behaves_like :get_resource_request, name: :episodes

    it "provides playable url" do
      pending "free channels dont have a token"
      do_request
      url = json_response.fetch(:episodes).fetch(:stream_url)
      expect(PlayableUrl.playable?(url)).to be_truthy
    end

    it "has a background image" do
      do_request
      expect(json_response[:episodes]).to have_key :background_image
    end

    describe "when resource not found" do
      def do_request
        super id: "not_found"
      end

      it_behaves_like :not_found
    end
  end

  describe "index" do
    let(:episodes) { json_response.fetch(:episodes) }
    def do_request(**params)
      super do
        get :index, {
          format: :json,
          show: show_id
        }.merge(params)
      end
    end

    it_behaves_like :get_collection_request, name: :episodes, limitable_by: 2

    it "doesn't have a stream_url" do
      do_request
      expect(episodes).not_to include have_key :stream_url
    end

    it "has a background image" do
      do_request
      expect(episodes).not_to include have_key :background_image
    end
  end
end

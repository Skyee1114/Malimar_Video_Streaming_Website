require "rails_helper"
require "support/shared_examples/requests"
require "support/vcr"
require "factories/user"
require "factories/resource/video"
require "factories/resource/container"

describe Resource::ChannelsController do
  include SpecHelpers::VcrDoRequest[:channels]

  let(:resource) { build :channel, :tea_tv }
  let(:grid_id) { build(:grid, :live_tv).id }

  describe "show" do
    def do_request(**params)
      super do
        get :show, {
          format: :json,
          id: resource.id,
          grid: grid_id
        }.merge(params)
      end
    end

    it_behaves_like :get_resource_request, name: :channels

    it "provides public stream url" do
      pending "free channels dont have a token"
      do_request
      url = json_response[:channels][:stream_url]
      expect(PlayableUrl.playable?(url)).to be_truthy
    end

    it "has a background image" do
      do_request
      expect(json_response[:channels]).to have_key :background_image
    end

    describe "when resource not found" do
      def do_request
        super id: "not_found"
      end

      it_behaves_like :not_found
    end

    describe "when requested not a channel resource" do
      def do_request
        super id: build(:show, :animals).id
      end

      it_behaves_like :not_found
    end

    describe "without grid" do
      def do_request(**_params)
        super grid: nil
      end

      it_behaves_like :get_resource_request, name: :channels
    end

    describe "container" do
      def do_request
        super include: "container"
      end

      it "includes container as linked object" do
        do_request
        channel = json_response[:channels]
        expect(channel.fetch(:links).fetch(:container)).to include id: "LiveTV_Free_Premium_Sponsors_CF"
      end
    end

    describe "recently played" do
      before { Audit::RecentlyPlayed.clear }
      before { sign_in user }

      describe "when user is registered" do
        let(:user) { create :user, :registered }

        it "adds channel to the recently played list" do
          expect do
            do_request
          end.to change { Audit.recently_played(user).count }.by +1
        end
      end

      describe "when user is a guest" do
        let(:user) { build :user, :guest }

        it "does not add new recently played entry" do
          expect do
            do_request
          end.not_to change { Audit.recently_played(user).count }
        end
      end
    end
  end
end

require "rails_helper"
require "support/shared_examples/requests"
require "support/vcr"
require "factories/resource/container"

describe Resource::ShowsController do
  include SpecHelpers::VcrDoRequest[:shows]
  let(:resource) { build :show, :animals }
  let(:grid_id) { build(:grid, :documentary).id }

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

    it_behaves_like :get_resource_request, name: :shows

    describe "episodes" do
      def do_request
        super include: "episodes"
      end

      it "includes episodes as objects" do
        do_request
        show = json_response.fetch(:shows)
        expect(show.fetch(:links).fetch(:episodes)).to include hash_including title: "Wonderful Animals | Episode 21  | Jun 08, 2019"
      end

      it "doesn't have a stream_url" do
        do_request
        episodes = json_response.fetch(:shows).fetch(:links).fetch(:episodes)
        expect(episodes).not_to include have_key :stream_url
      end
    end

    describe "latest_episode" do
      def do_request
        super include: "latest_episode"
      end

      it "includes episode as object" do
        do_request
        episode = json_response.fetch(:shows).fetch(:links).fetch(:latest_episode)
        expect(episode).to include title: /Wonderful Animals \| Episode \d+  \| .*/
      end

      it "latest episodes don't have a stream_url" do
        do_request
        episode = json_response.fetch(:shows).fetch(:links).fetch(:latest_episode)
        expect(episode).not_to have_key :stream_url
      end
    end

    describe "when resource not found" do
      def do_request
        super id: "not_found"
      end

      it_behaves_like :not_found
    end
  end
end

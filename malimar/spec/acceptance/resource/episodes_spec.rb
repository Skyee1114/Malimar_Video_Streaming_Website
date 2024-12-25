require "acceptance_helper"
require "factories/user"
require "factories/resource/video"
require "factories/resource/container"

resource "Episodes" do
  include_context :api

  module ResponseFields
    def self.included(example)
      example.with_options scope: :episodes do
        response_field :id,            "Episode id"
        response_field :title,         "Episode title"
        response_field :cover_image,   "Cover images of the resourse"
        response_field :number,        "Episode number in the show"
        response_field :release_date,  "Date when episode was released"
        response_field :synopsis,      "Synopsis", required: false
      end
    end
  end

  get "/episodes" do
    include SpecHelpers::VcrDoRequest[:episodes]
    response_field :episodes, "Episodes"

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    example_request "Get a list of episodes" do
      expect(response_status).to eq 404
    end
  end

  get "/episodes?show=:show_id" do
    include SpecHelpers::VcrDoRequest[:episodes]
    let!(:show) { build :show, :animals }
    let!(:episodes) { [build(:episode, :animals_21), build(:episode, :animals_20)] }

    parameter :show_id, "Show id"
    let(:show_id) { show.id }

    response_field :episodes,  "Episodes of the given show"
    response_field :href,      "Link to episode", scope: :episodes
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_collection, name: :episodes
    example_request "Get a list of episodes for given show" do
      episodes.each do |episode|
        expect(json_response[:episodes]).to include include(
          id: episode.id,
          title: episode.title
        )
      end
    end
  end

  get "/episodes?show=:show_id&limit=:limit" do
    include SpecHelpers::VcrDoRequest[:episodes]
    let!(:show) { build :show, :animals }
    let!(:episodes) { [build(:episode, :animals_21), build(:episode, :animals_20)] }

    parameter :show_id,  "Show id"
    parameter :limit,    "Limits the amout of episodes returned"
    let(:show_id) { show.id }
    let(:limit) { 1 }

    response_field :episodes,  "Episodes of the given show"
    response_field :href,      "Link to episode", scope: :episodes
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_collection, name: :episodes
    example_request "Get a list of episodes for given show limited to n episodes" do
      expect(json_response[:episodes].count).to eq limit
    end
  end

  get "/episodes/:id" do
    include SpecHelpers::VcrDoRequest[:episodes]
    let!(:episode) { build :episode, :animals_21 }

    parameter :id, "Episode id"
    let(:id) { episode.id }

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    example_request "Get episode information" do
      expect(response_status).to eq 404
    end
  end

  get "/episodes/:id?show=:show_id" do
    let(:api_user) { create :user, :premium }
    include SpecHelpers::VcrDoRequest[:episodes]
    let!(:episode) { build :episode, :animals_21 }
    let!(:show) { build :show, :animals }

    parameter :id,       "Episode id"
    parameter :show_id,  "Show id"
    let(:id) { episode.id }
    let(:show_id) { show.id }

    response_field :episodes, "Episode resource object"
    response_field :stream_url,        "Url with token to play the episode",      scope: :episodes
    response_field :player_url,        "Url to the player",                       scope: :episodes
    response_field :background_image,  "Huge background images of the resource",  scope: :episodes
    include ResponseFields

    pending "currently no free shows available"
    # it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :episodes
    example_request "Get episode for given show" do
      expect(json_response[:episodes]).to include(
        title: episode.title,
        id: episode.id
      )
    end

    describe "premium episode" do
      let(:api_user) { create :user, :registered }
      let!(:episode) { build :episode, :hmong_2 }
      let!(:show) { build :show, :hmong }

      example_request "Get premium episode on free subscription" do
        expect(response_status).to eq 403
      end
    end
  end
end

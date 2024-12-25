require "acceptance_helper"
require "factories/user"
require "factories/resource/video"
require "factories/resource/container"

resource "Channels" do
  include_context :api

  module ResponseFields
    def self.included(example)
      example.response_field :channels, "Channel resource object"
      example.with_options scope: :channels do
        response_field :id,                "Channel id"
        response_field :title,             "Channel title"
        response_field :cover_image,       "Cover images of the resource"
        response_field :background_image,  "Huge background images of the resource"
        response_field :synopsis,          "Synopsis"
        response_field :stream_url,        "Url with token to play the channel"
        # response_field :player_url,        "Url to the player"
      end
    end
  end

  get "/channels/:id" do
    include SpecHelpers::VcrDoRequest[:channels]
    let!(:channel) { build :channel, :tea_tv }

    parameter :id, "Channel id"
    let(:id) { channel.id }

    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :channels
    example_request "Get channel information" do
      expect(json_response[:channels]).to include(
        title: channel.title,
        id: channel.id
      )
    end
  end

  get "/channels/:id?include=container" do
    include SpecHelpers::VcrDoRequest[:channels]
    let!(:channel) { build :channel, :tea_tv }

    parameter :id, "Channel id"
    let(:id) { channel.id }

    response_field :links, "Embedded resources", scope: :channels
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :channels
    example_request "Get channel information with embedded container" do
      loaded_channel = json_response[:channels]

      expect(loaded_channel).to include(
        id: channel.id
      )

      expect(loaded_channel).to include(
        links: have_key(:container)
      )

      expect(loaded_channel[:links][:container]).to have_key :id
    end
  end

  get "/channels/:id?grid=:grid_id" do
    include SpecHelpers::VcrDoRequest[:channels]
    let!(:channel) { build :channel, :tea_tv }
    let!(:grid) { build :grid, :live_tv }

    parameter :id,       "Channel id"
    parameter :grid_id,  "Grid id"
    let(:id) { channel.id }
    let(:grid_id) { grid.id }

    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :channels
    example_request "Get channel for given grid" do
      expect(json_response[:channels]).to include(
        title: channel.title,
        id: channel.id
      )
    end

    describe "premium channel" do
      let!(:channel) { build :channel, :thai5 }
      let!(:grid) { build :grid, :premium_tv }

      example_request "Get premium channel on free subscription" do
        expect(response_status).to eq 403
      end
    end
  end
end

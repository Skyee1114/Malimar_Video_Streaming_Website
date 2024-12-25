# frozen_string_literal: true

require "acceptance_helper"
require "factories/user"
require "factories/resource/video"
require "support/vcr"

resource "Favorite Videos" do
  include_context :api

  module ResponseFields
    def self.included(example)
      example.with_options scope: :favorite_videos do
        response_field :id,                   "Resource id"
        response_field :title,                "Resource title"
        response_field :href,                 "Link to resource"
        response_field :cover_image,          "Cover images of the resourse"
        response_field :synopsis,             "Brief description", required: false
        response_field :type,                 "Type of the resource"
        response_field :is_recently_updated,  "Boolean. True when resource was updated"
        response_field :highlight,            "Extra information", required: false
      end
    end
  end

  module ParameterFields
    def self.included(example)
      example.parameter :links, "Links", scope: :favorite_videos

      example.let(:container) { build :show, :animals }
      example.let(:video) { build :episode, :animals_21 }

      example.let(:links) do
        {
          user: api_user.id,
          container: container.id,
          video: video.id
        }
      end
    end
  end

  get "/favorite_videos?user=:user_id" do
    let!(:favorite_video) { build :channel, :favorite_by, user: api_user }
    let(:user_id) { api_user.id }

    response_field :favorite_videos, "List of thumbnails"
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_collection, name: :favorite_videos
    example_request "Get a list of favorite videos for a user" do
      expect(json_response[:favorite_videos]).to include include(
        id: favorite_video.id
      )
    end
  end

  delete "/favorite_videos/:id?user=:user_id" do
    let!(:favorite_video) { build :channel, :favorite_by, user: api_user }
    let(:id) { favorite_video.id }
    let(:user_id) { api_user.id }

    response_field :favorite_videos, "List of thumbnails"
    include ResponseFields

    it_behaves_like :authentication_required
    it_behaves_like :json_compatible
    it_behaves_like :json_api_no_content
    example_request "Remove a video from user's favorite videos list" do
      expect(FavoriteVideoList.new(api_user).resources).not_to include favorite_video
    end
  end

  post "/favorite_videos" do
    include SpecHelpers::VcrDoRequest[:channels]
    parameter :favorite_videos, "Favorite video params"
    include ParameterFields

    response_field :favorite_videos, "Favorite video resource object"
    include ResponseFields

    it_behaves_like :authentication_required
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :favorite_videos

    example "Add new favorite video" do
      expect do
        do_request
      end.to change { FavoriteVideoList.new(api_user).resources.count }.by +1
    end
  end
end

require "acceptance_helper"
require "factories/user"
require "factories/resource/video"

resource "Recently played" do
  include_context :api
  before { Audit::RecentlyPlayed.clear }

  module ResponseFields
    def self.included(example)
      example.with_options scope: :recently_played do
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

  get "/recently_played" do
    let!(:recently_played_video) { build :channel, :recently_played, user: api_user }

    response_field :recently_played, "List of thumbnails"
    include ResponseFields

    it_behaves_like :authentication_required
    it_behaves_like :json_compatible
    it_behaves_like :json_api_collection, name: :recently_played
    example_request "Get a list of recently played videos for user" do
      expect(json_response[:recently_played]).to include include(
        id: recently_played_video.id
      )
    end
  end

  delete "/recently_played/:id" do
    let!(:recently_played_video) { build :channel, :recently_played, user: api_user }
    let(:id) { recently_played_video.id }

    response_field :recently_played, "List of thumbnails"
    include ResponseFields

    it_behaves_like :authentication_required
    it_behaves_like :json_compatible
    it_behaves_like :json_api_no_content
    example_request "Remove a recently played video" do
      expect(Audit::RecentlyPlayed.new(api_user).resources).not_to include(recently_played_video)
    end
  end
end

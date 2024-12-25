require "acceptance_helper"
require "factories/user"
require "factories/resource/container"
require "factories/resource/video"

resource "Thumbnails" do
  include_context :api

  module ResponseFields
    def self.included(example)
      example.with_options scope: :thumbnails do
        response_field :id,                   "Resource id"
        response_field :title,                "Resource title"
        response_field :href,                 "Link to resource"
        response_field :cover_image,          "Cover images of the resourse"
        response_field :synopsis,             "Brief description", required: false
        response_field :type,                 "Type of the resource"
        response_field :is_recently_updated,  "Boolean. True when resource was updated"
        response_field :highlight,            "Additional information", required: false
      end
    end
  end

  get "/thumbnails" do
    include SpecHelpers::VcrDoRequest[:thumbnails]
    response_field :thumbnails, "Thumbnail resourses"

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    example_request "Get a list of thumbnails" do
      expect(response_status).to eq 404
    end
  end

  get "/thumbnails?container=:container_id" do
    include SpecHelpers::VcrDoRequest[:thumbnails]
    let!(:container) { build :grid, :documentary }
    let!(:show) { build(:show, :animals) }

    parameter :container_id, "Container id: show or dashboard id for example"
    let(:container_id) { container.id }

    response_field :thumbnails, "Thumbnails for the elements in given container"
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_collection, name: :thumbnails
    example_request "Get a list of thumbnails for given container" do
      expect(json_response[:thumbnails]).to include include(
        id: show.id,
        title: show.title
      )
    end

    describe "thumnails for the show" do
      let!(:container) { show }
      let!(:episode) { build :episode, :animals_21 }
      it_behaves_like :json_api_collection, name: :thumbnails
      example_request "Get episodes as thumbnails for the show" do
        expect(json_response[:thumbnails]).to include include(
          id: episode.id
        )
      end
    end
  end

  get "/thumbnails?container=:container_id&limit=:limit" do
    include SpecHelpers::VcrDoRequest[:thumbnails]
    let!(:container) { build :grid, :documentary }
    let!(:show) { build(:show, :animals) }

    parameter :container_id, "Container id: show or dashboard id for example"
    parameter :limit,  "Limits the amout of thumbnails returned"
    let(:container_id) { container.id }
    let(:limit) { 1 }

    response_field :thumbnails, "Thumbnails for the elements in given container"
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_collection, name: :thumbnails
    example_request "Get a list of thumbnails limited to n elements" do
      expect(json_response[:thumbnails].count).to eq limit
    end
  end
end

require "acceptance_helper"
require "factories/user"
require "factories/resource/container"

resource "Shows" do
  include_context :api

  module ResponseFields
    def self.included(example)
      example.with_options scope: :shows do
        response_field :id,           "Show id"
        response_field :title,        "Show title"
        response_field :cover_image,  "Cover images of the resourse"
      end
    end
  end

  get "/shows/:id" do
    include SpecHelpers::VcrDoRequest[:shows]
    let!(:show) { build :show, :animals }

    parameter :id, "Show id"
    let(:id) { show.id }

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    example_request "Get show information" do
      expect(response_status).to eq 404
    end
  end

  get "/shows/:id?grid=:grid_id" do
    include SpecHelpers::VcrDoRequest[:shows]
    let!(:show) { build :show, :animals }
    let!(:grid) { build :grid, :documentary }

    parameter :id,       "Show id"
    parameter :grid_id,  "Grid id"
    let(:id) { show.id }
    let(:grid_id) { grid.id }

    response_field :shows,  "Show resource object"
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :shows
    example_request "Get show from the grid" do
      expect(json_response[:shows]).to include(
        title: show.title,
        id: show.id
      )
    end
  end

  get "/shows/:id?include=episodes&grid=:grid_id" do
    include SpecHelpers::VcrDoRequest[:shows]
    let!(:show) { build :show, :animals }
    let!(:grid) { build :grid, :documentary }

    parameter :id,       "Show id"
    parameter :grid_id,  "Grid id"
    let(:id) { show.id }
    let(:grid_id) { grid.id }

    response_field :shows,  "Show resource object"
    response_field :links,  "Embedded resources", scope: :shows
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :shows
    example_request "Get show from the grid with embedded episodes" do
      loaded_show = json_response[:shows]

      expect(loaded_show).to include(
        title: show.title,
        id: show.id
      )

      expect(loaded_show).to include(
        links: have_key(:episodes)
      )

      expect(loaded_show[:links][:episodes]).to be_a Array
    end
  end
end

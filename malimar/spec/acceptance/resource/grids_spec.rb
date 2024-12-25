require "acceptance_helper"
require "factories/user"
require "factories/resource/container"

resource "Grids" do
  include_context :api

  module ResponseFields
    def self.included(example)
      example.with_options scope: :grids do
        response_field :id,                "Grid id"
        response_field :title,             "Grid title"
        response_field :title_translated,  "Grid title in another language", required: false
      end
    end
  end

  get "/grids" do
    include SpecHelpers::VcrDoRequest[:grids]
    let!(:grids) { [build(:grid, :live_tv), build(:grid, :premium_tv)] }

    response_field :grids,  "Grids of the home dashboard"
    response_field :href,   "Link to grid", scope: :grids
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_collection, name: :grids
    example_request "Get a list of grids" do
      grids.each do |grid|
        expect(json_response[:grids]).to include include(
          id: grid.id
        )
      end
    end
  end

  get "/grids?dashboard=:dashboard_id" do
    include SpecHelpers::VcrDoRequest[:grids]
    let!(:dashboard) { build :dashboard, :lao }
    let!(:grids) { [build(:grid, :lao_music), build(:grid, :lao_movie)] }

    parameter :dashboard_id, "Dashboard id"
    let(:dashboard_id) { dashboard.id }

    response_field :grids,  "Grids of the given dashboard"
    response_field :href,   "Link to grid", scope: :grids
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_collection, name: :grids
    example_request "Get a list of grids for given dashboard" do
      grids.each do |grid|
        expect(json_response[:grids]).to include include(
          id: grid.id
        )
      end
    end
  end

  get "/grids?include=thumbnails&limit=:limit" do
    include SpecHelpers::VcrDoRequest[:grids]
    let!(:grids) { [build(:grid, :live_tv)] }

    parameter :limit, "Limits the amout of grids returned"
    let(:limit) { 2 }

    response_field :grids,  "Grids of the home dashboard"
    response_field :href,   "Link to grid",                scope: :grids
    response_field :links,  "Embedded resources",          scope: :grids
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_collection, name: :grids
    example_request "Get a list of grids with thumbnails embedded limited to n grids" do
      grids.each do |grid|
        expect(json_response[:grids].count).to eq limit
        expect(json_response[:grids]).to include include(
          id: grid.id
        )

        expect(json_response[:grids]).to include(
          hash_including(links: have_key(:thumbnails))
        )
      end
    end
  end

  get "/grids/:id" do
    include SpecHelpers::VcrDoRequest[:grids]
    let!(:grid) { build :grid, :live_tv }

    parameter :id, "Grid id"
    let(:id) { grid.id }

    response_field :grids, "Grid resource object"
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :grids
    example_request "Get grid information" do
      expect(json_response[:grids]).to include(
        id: grid.id
      )
    end
  end

  get "/grids/:id?include=thumbnails" do
    include SpecHelpers::VcrDoRequest[:grids]
    let!(:grid) { build :grid, :live_tv }

    parameter :id, "Grid id"
    let(:id) { grid.id }

    response_field :grids,  "Grid resource object"
    response_field :links,  "Embedded resources", scope: :grids
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_resource, name: :grids
    example_request "Get grid information with embedded thumbnails" do
      loaded_grid = json_response[:grids]

      expect(loaded_grid).to include(
        id: grid.id
      )

      expect(loaded_grid).to include(
        links: have_key(:thumbnails)
      )

      expect(loaded_grid[:links][:thumbnails]).to be_a Array
    end
  end
end

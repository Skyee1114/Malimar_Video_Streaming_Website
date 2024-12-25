require "rails_helper"
require "support/shared_examples/requests"
require "support/vcr"
require "factories/resource/container"

describe Resource::GridsController do
  include SpecHelpers::VcrDoRequest[:grids]
  let(:resource) { build :grid, :live_tv }

  describe "index" do
    def do_request(**params)
      super do
        get :index, format: :json, **params
      end
    end

    it_behaves_like :get_collection_request, name: :grids, limitable_by: 2

    describe "premium dashboard" do
      def do_request(**params)
        super({
          dashboard: dashboard.id
        }.merge(params))
      end

      let(:dashboard) { build :dashboard, :hmong }
      let(:resource) { build :grid, :hmong_tv }

      it_behaves_like :get_collection_request, name: :grids, limitable_by: 2
    end
  end

  describe "show" do
    def do_request(**params)
      super do
        get :show, {
          format: :json,
          id: resource.id
        }.merge(params)
      end
    end

    it_behaves_like :get_resource_request, name: :grids

    describe "thumbnails" do
      def do_request
        super include: "thumbnails"
      end

      it "includes thumbnails as linked objects" do
        do_request
        grid = json_response[:grids]
        expect(grid.fetch(:links).fetch(:thumbnails)).to include hash_including title: "TEA TV"
      end

      it "thumbnails do not have a link back to grid" do
        do_request
        thumbnails = json_response[:grids][:links][:thumbnails]
        expect(thumbnails).not_to include hash_including grid: anything
      end
    end

    describe "for HomeGrid dashboard" do
      def do_request(**_params)
        super dashboard: "HomeGrid"
      end

      it_behaves_like :get_resource_request, name: :grids
    end

    describe "for Home dashboard" do
      def do_request(**_params)
        super dashboard: "Home"
      end

      it_behaves_like :get_resource_request, name: :grids
    end
  end
end

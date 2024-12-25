require "rails_helper"
require "support/shared_examples/requests"
require "support/vcr"
require "factories/resource/video"
require "factories/resource/container"

describe Resource::ThumbnailsController do
  include SpecHelpers::VcrDoRequest[:thumbnails]
  let(:resource) { build :show, :animals }
  let(:container) { build :grid, :documentary }

  describe "index" do
    def do_request(**params)
      super do
        get :index, {
          format: :json,
          container: container.id
        }.merge(params)
      end
    end

    it_behaves_like :get_collection_request, name: :thumbnails, limitable_by: 2

    describe "episodes" do
      let(:resource) { build :episode, :animals_21 }
      let(:container) { build :show, :animals }
      it "uses episode number as title" do
        do_request limit: 2
        expect(json_response[:thumbnails]).to include include(
          title: /Episode \d+/
        )
      end
    end

    describe "cover image" do
      it "contains the wide version" do
        do_request limit: 1
        cover_image = json_response[:thumbnails][0].fetch :cover_image
        expect(cover_image).to have_key :wide
        expect(cover_image.fetch(:wide)).not_to be_blank
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"
require "factories/user"
require "factories/resource/video"
require "support/vcr"
require "support/shared_examples/requests"

describe FavoriteVideosController do
  let(:resource) { build :channel, :favorite_by, user: user }
  let(:user) { create :user, :registered }
  before { sign_in user }

  describe "index" do
    def do_request(**params)
      get :index, { format: :jsonapi, user: user.id }.merge(params)
    end

    it_behaves_like :get_collection_request, name: :favorite_videos
  end

  describe "destroy" do
    def do_request(**_attributes)
      delete :destroy, { format: :jsonapi, id: resource.id, user: user }
    end

    it_behaves_like :delete_resource_request, name: :favorite_videos
  end

  describe "create" do
    include SpecHelpers::VcrDoRequest[:episodes]
    let(:resource) { build :episode, :animals_21 }
    let(:container) { build :show, :animals }

    def do_request(**_attributes)
      super do
        post :create, { format: :jsonapi, favorite_videos: {
          links: {
            user: user.id,
            video: resource.id,
            container: container.id
          }
        } }
      end
    end

    it_behaves_like :create_resource_request, name: :favorite_videos, persisted: false do
      let(:respond_with) { { id: resource.id } }
    end
  end
end

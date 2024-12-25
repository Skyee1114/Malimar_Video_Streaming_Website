require "rails_helper"
require "support/shared_examples/requests"

describe CountriesController do
  let(:resource) do
    ISO3166::Country["US"].tap do |country|
      def country.id
        alpha2
      end
    end
  end

  describe "index" do
    def do_request(**params)
      get :index, format: :json, **params
    end

    it_behaves_like :get_collection_request, name: :countries
  end
end

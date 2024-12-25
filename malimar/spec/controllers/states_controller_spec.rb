require "rails_helper"
require "support/shared_examples/requests"

describe StatesController do
  let(:resource) { OpenStruct.new id: "AL", name: "Alabama" }
  let(:country_id) { "US" }

  describe "index" do
    def do_request(**params)
      get :index, {
        format: :json,
        country: country_id
      }.merge(params)
    end

    it_behaves_like :get_collection_request, name: :states

    describe "when country not found" do
      let(:country_id) { "no_such_country" }

      it_behaves_like :not_found
    end
  end
end

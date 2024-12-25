require "acceptance_helper"
require "factories/user"
require "countries"

resource "States" do
  include_context :api

  module ResponseFields
    def self.included(example)
      example.with_options scope: :states do
        response_field :id,    "State code"
        response_field :name,  "State name"
      end
    end
  end

  get "/states?country=:country_id" do
    parameter :country_id,  "Country id"
    let(:country_id) { "US" }

    response_field :states, "List of states in given country"
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_collection, name: :states
    example_request "Get a list of states for given country" do
      expect(json_response[:states]).to include include(
        id: "AL",
        name: "Alabama"
      )
    end
  end
end

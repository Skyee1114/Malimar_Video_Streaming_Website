require "acceptance_helper"
require "factories/user"
require "countries"

resource "Countries" do
  include_context :api

  module ResponseFields
    def self.included(example)
      example.with_options scope: :countries do
        response_field :id,    "Country code"
        response_field :name,  "Country name"
      end
    end
  end

  get "/countries" do
    let!(:country) { ISO3166::Country["US"] }

    response_field :countries, "List of countries"
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_collection, name: :countries
    example_request "Get a list of countries" do
      expect(json_response[:countries]).to include include(
        id: country.alpha2,
        name: country.translation
      )
    end
  end
end

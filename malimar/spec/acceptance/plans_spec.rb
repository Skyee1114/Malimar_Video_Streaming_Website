require "acceptance_helper"
require "factories/user"
require "factories/plan"

resource "Plans" do
  include_context :api

  module ResponseFields
    def self.included(example)
      example.with_options scope: :plans do
        response_field :id,                     "Plan id"
        response_field :name,                   "Plan name"
        response_field :description,            "Plan description", required: false
        response_field :cost,                   "Plan cost"
        response_field :period_in_monthes,      "Integer amout of monthes"
        response_field :includes_web_content,   "Is web access granted"
        response_field :includes_roku_content,  "Is roku access granted"
        response_field :includes_hardware,      "Is hardware provided with the plan"
      end
    end
  end

  get "/plans" do
    let!(:plans) { [create(:plan, :web, :one_month)] }

    response_field :plans, "Available plans"
    include ResponseFields

    it_behaves_like :publicly_available
    it_behaves_like :json_compatible
    it_behaves_like :json_api_collection, name: :plans
    example_request "Get a list of plans" do
      plans.each do |plan|
        expect(json_response[:plans]).to include include(
          id: plan.id,
          name: plan.name,
          includes_web_content: true
        )
      end
    end
  end
end

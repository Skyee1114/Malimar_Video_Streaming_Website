require "countries"

class CountriesController < ApiController
  def index
    load_countries
    render json: @countries
  end

  private

  def load_countries
    @countries = policy_scope(
      ISO3166::Country.translations.to_a,
      policy: DataPolicy
    )
  end
end

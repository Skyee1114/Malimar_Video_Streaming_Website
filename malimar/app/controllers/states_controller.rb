require "countries"

class StatesController < ApiController
  def index
    load_states
    render json: @states
  end

  private

  def load_states
    @states = policy_scope(
      country.states.to_a,
      policy: DataPolicy
    )
  end

  def country
    ISO3166::Country[params[:country]] || raise(Resource::NotFoundError)
  end
end

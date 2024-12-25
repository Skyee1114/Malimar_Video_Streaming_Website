class PlansController < ApiController
  def index
    load_plans
    render json: @plans
  end

  private

  def load_plans
    @plans = policy_scope(
      plan_scope,
      policy: PlanPolicy
    )
  end

  def plan_scope
    Plan.all.ordered
  end
end

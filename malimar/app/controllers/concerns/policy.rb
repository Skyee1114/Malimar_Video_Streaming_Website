module Policy
  include Pundit

  def policy_scope(scope, policy: nil, owner: nil)
    return super scope if policy.nil?

    skip_policy_scope
    @policy_scope || policy::Scope.new(pundit_user, scope, owner: owner).resolve
  end

  def authorize(record, policy: nil, query: nil, owner: nil)
    query ||= params[:action].to_s + "?"
    skip_authorization

    policy_instance = policy.new pundit_user, record, owner: owner if policy
    policy_instance ||= policy(record)

    unless policy_instance.public_send(query)
      raise NotAuthorizedError.new query: query, record: record, policy: policy_instance
    end

    true
  end
end

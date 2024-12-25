# frozen_string_literal: true

require "forwardable"

class ApplicationPolicy
  extend Forwardable
  def_delegators :subscription, :has_access_to?
  def_delegators :user, *User::Types.verifier_methods

  attr_reader :user, :resource, :resource_owner

  def initialize(user, resource, owner: User::Mimic.new)
    @user = user
    @resource = resource
    @resource_owner = owner
  end

  private

  def subscription
    @subscription ||= user.subscription
  end

  class Scope
    attr_reader :user, :scope, :resource_owner

    def initialize(user, scope, owner: User::Mimic.new)
      @user = user
      @scope = scope
      @resource_owner = owner
    end

    def resolve
      scope
    end
  end
end

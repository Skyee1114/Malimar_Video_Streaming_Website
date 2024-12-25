require "forwardable"

class SusspiciousActivityPresenter
  extend Forwardable
  def_delegators :user, :login, :email

  def initialize(activity, user, old_expiration:)
    @activity = activity
    @user = user
    @old_expiration = old_expiration
  end

  attr_reader :old_expiration

  private

  attr_reader :activity, :user
end

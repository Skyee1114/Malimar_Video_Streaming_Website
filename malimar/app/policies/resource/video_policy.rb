module Resource
  class VideoPolicy < ApplicationPolicy
    def show?
      return true if feature_active? :free

      return registered? || resource.has_free_content? unless feature_active? :subscription

      !(restricted_adult_content? ||
        restricted_premium_content?)
    end

    private

    def restricted_adult_content?
      resource.has_adult_content? && !has_access_to?(:adult)
    end

    def restricted_premium_content?
      resource.has_premium_content? && !has_access_to?(:premium)
    end
  end
end

module Resource
  class ContainerPolicy < ApplicationPolicy
    HIDDEN_CONTAINERS = %w[LiveTV_Free_English_CF Cartoon_CF Movie_New_Arrivals_CF Movies_CF].freeze

    def show?
      !hidden? resource
    end

    class Scope < Scope
      def resolve
        scope.select do |resource|
          ContainerPolicy.new(user, resource).show?
        end
      end
    end

    private

    def hidden?(resource)
      HIDDEN_CONTAINERS.include? resource.id
    end
  end
end

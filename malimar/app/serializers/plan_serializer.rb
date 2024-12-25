require_relative "serializer"

class PlanSerializer < Serializer
  attributes :id, :name, :description, :cost, :period_in_monthes,
             :includes_web_content,
             :includes_roku_content,
             :includes_hardware
end

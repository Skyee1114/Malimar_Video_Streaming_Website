class Plan < ActiveRecord::Base
  scope :ordered, -> { order(includes_hardware: :asc, includes_roku_content: :desc, period_in_monthes: :asc) }
end

# frozen_string_literal: true

feature :subscription do
  feature_active?(:registration) && true
end

feature :registration do
  true
end

feature :roku do
  false
end

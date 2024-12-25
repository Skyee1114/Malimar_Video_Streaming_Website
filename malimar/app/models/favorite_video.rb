# frozen_string_literal: true

class FavoriteVideo < ActiveRecord::Base
  belongs_to :user, class_name: "User::Local"
  scope :for_user, ->(user) { where(user_id: user.id) }
end

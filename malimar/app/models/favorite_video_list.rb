# frozen_string_literal: true

class FavoriteVideoList
  def self.video_db
    @video_db ||= Redis::Store::Factory.create "redis://#{ENV['REDIS_HOST']}:6379/0/videos"
  end

  def initialize(user, video_db: self.class.video_db)
    @user = user
    @video_db = video_db
  end

  def resources
    sorted_favorites.map do |record|
      deserialize record.video_id
    end.compact
  end

  def add(resource)
    update_in_db resource
    add_to_favorites resource
  end

  def remove(resource)
    favorites.where(video_id: resource.id).destroy_all
  end

  private

  attr_reader :user, :video_db

  def update_in_db(resource)
    video_db.set resource.id, serialize(resource)
  end

  def add_to_favorites(resource)
    favorites.find_or_create_by!(video_id: resource.id)
  end

  def serialize(resource)
    resource.to_json
  end

  def deserialize(video_id)
    record = video_db.get video_id
    return nil unless record

    json = JSON.parse record
    Resource::Video.new(json)
  end

  def sorted_favorites
    favorites.order(updated_at: :DESC)
  end

  def favorites
    FavoriteVideo.for_user(user)
  end
end

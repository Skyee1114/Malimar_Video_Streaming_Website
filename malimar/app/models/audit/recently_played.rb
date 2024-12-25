require_relative "../audit"

module Audit
  class RecentlyPlayed
    def self.clear
      new(nil).clear_db
    end

    def self.recently_played_db
      @recently_played_db ||= Redis::Store::Factory.create "redis://#{ENV['REDIS_HOST']}:6379/0/recently_played"
    end

    def self.video_db
      @video_db ||= Redis::Store::Factory.create "redis://#{ENV['REDIS_HOST']}:6379/0/videos"
    end

    def initialize(user, maximum_size: ENV["RECENTLY_PLAYED_SIZE"], recently_played_db: self.class.recently_played_db, video_db: self.class.video_db)
      @user = user
      @recently_played_db = recently_played_db
      @video_db = video_db
      @maximum_size = Integer(maximum_size)
    end

    def resources
      raw_data.map do |record|
        deserialize record
      end.compact
    end

    def add(resource)
      update_in_db resource
      add_to_recently_played_list resource
      trim_tail
    end

    def remove(resource)
      remove_from_list resource.id
    end

    def clear_db
      recently_played_db.flushdb
      video_db.flushdb
    end

    private

    attr_reader :user, :recently_played_db, :video_db, :maximum_size

    def bucket
      user.id.to_s
    end

    def trim_tail
      recently_played_db.ltrim bucket, 0, (maximum_size - 1)
    end

    def update_in_db(resource)
      video_db.set resource.id, serialize(resource)
    end

    def add_to_recently_played_list(resource)
      remove_from_list resource.id
      recently_played_db.lpush bucket, resource.id
    end

    def serialize(resource)
      resource.to_json
    end

    def deserialize(record_id)
      record = video_db.get record_id
      return nil unless record

      json = JSON.parse record
      Resource::Video.new(json)
    end

    def raw_data
      recently_played_db.lrange bucket, 0, -1
    end

    def remove_from_list(id)
      recently_played_db.lrem bucket, 1, id
    end
  end
end

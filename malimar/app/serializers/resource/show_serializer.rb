require_relative "../serializer"

class Resource::ShowSerializer < Serializer
  self.root = "shows"
  attributes :id, :title, :cover_image

  has_many :episodes, each_serializer: Resource::EpisodeSerializer
  has_one :latest_episode, serializer: Resource::EpisodeSerializer

  def episodes
    @episodes ||= load_episodes
  end

  def latest_episode
    episodes.first
  end

  private

  def load_episodes
    policy_scope(
      Resource.all(object),
      policy: Resource::VideoPolicy
    )
  end
end

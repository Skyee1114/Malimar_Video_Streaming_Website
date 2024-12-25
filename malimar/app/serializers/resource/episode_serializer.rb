require_relative "../serializer"

class Resource::EpisodeSerializer < Serializer
  self.root = "episodes"
  attributes :id, :title, :synopsis, :cover_image, :number, :release_date, :href

  def href
    episode_url object.id, show: object.container.id
  end
end

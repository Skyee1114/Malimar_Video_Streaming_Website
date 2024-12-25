require_relative "../serializer"
require_relative "thumbnail_serializer"

class Resource::GridSerializer < Serializer
  self.root = "grids"
  attributes :id, :title, :title_translated, :href

  has_many :thumbnails, each_serializer: Resource::ThumbnailSerializer

  def thumbnails
    @thumbnails ||= load_thumbnails
  end

  def href
    grid_url object.id, dashboard: object.container.id
  end

  def title
    object.title.sub /\AROW\s+\d+\s+/, ""
  end

  private

  def load_thumbnails
    policy_scope(
      Resource.all(object),
      policy: Resource::ThumbnailsPolicy
    )
  end
end

require_relative "../serializer"

class Resource::ThumbnailSerializer < Serializer
  self.root = "thumbnails"
  attributes :id, :title, :cover_image, :href, :type, :synopsis, :is_recently_updated, :highlight

  def href
    case object.type
    when :channel   then channel_url   object.id,  grid: object.container.id
    when :show      then show_url      object.id,  grid: object.container.id
    when :episode   then episode_url   object.id,  show: object.container.id
    when :dashboard then dashboard_url object.id
    end
  end

  def synopsis
    return object.synopsis if object.respond_to? :synopsis
    return object.description if object.respond_to? :description
  end

  def is_recently_updated
    object.recently_updated?
  end

  def highlight
    case object.type
    when :episode then "Episode #{object.number}"
    end
  end
end

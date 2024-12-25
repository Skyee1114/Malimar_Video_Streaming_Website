require_relative "../serializer"

class Resource::FeedSerializer < Serializer
  self.root = "feeds"
  attributes :id
end

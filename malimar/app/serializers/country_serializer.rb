require_relative "serializer"

class CountrySerializer < Serializer
  self.root = "countries"
  attributes :id, :name

  def id
    object.first
  end

  def name
    object.last
  end
end

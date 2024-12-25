require_relative "serializer"
require "countries"

class StateSerializer < Serializer
  self.root = "states"
  attributes :id, :name

  def id
    id = object.first
    return id if id_state?

    name.parameterize.capitalize
  end

  def name
    @name ||= translated_name.sub(/\(.+\)/, "").sub(/\[.+\]/, "").gsub("'", "").strip
  end

  private

  def translated_name
    object.last["name"] || object.last.translations["en"] || object.last.translations.first.last
  end

  def id_state?
    id_state_names.include? name
  end

  def id_state_names
    @id_state_names ||= (ISO3166::Country["US"].states.merge ISO3166::Country["CA"].states).map do |_state_abbr, state_data|
      state_data["name"]
    end
  end
end

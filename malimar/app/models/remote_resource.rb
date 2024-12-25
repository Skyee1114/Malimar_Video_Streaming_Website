require "active_support/core_ext/object/try"
require "active_model"
require "active_model/serializers/xml"

class RemoteResource
  def initialize(item_document, document:, source:)
    @item_document = item_document
    @document = document
    @source = source
  end
  attr_reader :source

  def feed_type
    @feed ||= item_document.at_css "feed[type]"
    @feed["type"] if @feed
  end

  def has_field?(key)
    item_document.css(key.to_s).any?
  end

  def content_type
    item_document.at_css("MSUB").try(:text) ||
      document.at_css("MSUB").try(:text)
  end

  def to_h
    Hash.from_xml(item_document.to_xml).fetch item_document.name
  end

  private

  attr_reader :item_document, :document
end

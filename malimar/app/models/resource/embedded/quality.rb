require "virtus"

module Resource::Embedded
  class Quality
    include Virtus.value_object

    values do
      attribute :category,  String
      attribute :bitrate,   Integer
    end
  end
end

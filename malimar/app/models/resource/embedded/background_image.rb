require "virtus"

module Resource
  module Embedded
    class BackgroundImage
      include Virtus.value_object

      values do
        attribute :sd, String
        attribute :hd, String
      end
    end
  end
end

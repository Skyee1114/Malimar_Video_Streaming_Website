module Virtus
  class Attribute
    # EmbeddedValue handles virtus-like objects, OpenStruct and Struct
    #
    class EmbeddedValue < Attribute
      TYPES = [Struct, OpenStruct, Virtus, Model::Constructor, ActiveRecord::Base].freeze

      # @api private
      def self.build_coercer(type, _options)
        primitive = type.primitive

        if primitive < Virtus || primitive < Model::Constructor || primitive <= OpenStruct || primitive < ActiveRecord::Base
          FromOpenStruct.new(type)
        elsif primitive < Struct
          FromStruct.new(type)
        end
      end
    end # class EmbeddedValue
  end # class Attribute
end # module Virtus

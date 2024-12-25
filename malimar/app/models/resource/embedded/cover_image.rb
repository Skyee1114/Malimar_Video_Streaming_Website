require "virtus"
require "active_support/core_ext/object"

module Resource
  module Embedded
    class CoverImage
      include Virtus.value_object

      values do
        attribute :sd,     String
        attribute :hd,     String
        attribute :wide,   String, default: :build_wide_image
      end

      def hd
        WideCoverImage.call(apply_rewrite_rules(super))
      end

      def sd
        WideCoverImage.call(apply_rewrite_rules(super))
      end

      private

      # FIXME: remove when XML will provide it
      def build_wide_image
        return if hd.blank?

        parts = hd.match(/(.*?)F?\.(\w+)\z/)
        return if parts.blank?

        name, ext = parts.captures
        "#{name}-large.#{ext}"
      end

      def apply_rewrite_rules(url)
        RewriteRule.apply(url, subject: :image)
      end
    end
  end
end

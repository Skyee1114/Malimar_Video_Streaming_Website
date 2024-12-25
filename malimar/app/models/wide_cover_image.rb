class WideCoverImage
  WIDE_SYMBOL = "F".freeze

  class << self
    def call(url)
      return url if url.blank?

      ext = File.extname url
      path_without_ext = url.chomp(ext)

      return url if path_without_ext[-1] == WIDE_SYMBOL

      [
        path_without_ext,
        WIDE_SYMBOL,
        ext
      ].join
    end
  end
end

# frozen_string_literal: true

module WebClient::RobotsHelper
  NO_INDEX_PATH = %w[episode].freeze
  def robots_index_directive
    skip_page? ? "noindex" : "index"
  end

  private

  def skip_page?
    request.path.to_s =~
      %r{
        (episodes/\w+)
        |
        (channels/\w+)
      }ix
  end
end

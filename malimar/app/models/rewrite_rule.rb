require "local_cache"

class RewriteRule < ActiveRecord::Base
  SUBJECTS = %i[url image].freeze
  enum subject: SUBJECTS

  class << self
    def apply(url, subject:)
      rules_for(subject).inject(url) do |url, rule|
        rule.apply url
      end
    end

    private

    def rules_for(subject)
      LocalCache.fetch subject, expires_in: 1.hour do
        public_send(subject).all
      end
    end
  end

  def apply(url)
    return unless url

    url.sub from, to
  end
end

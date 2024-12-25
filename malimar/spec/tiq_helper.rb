require "spec_helper"

unless defined? Sidekiq
  module Sidekiq
    Worker = Module.new
  end
end

unless defined? Sidetiq
  module Sidetiq
    module Schedulable
      def self.included(base)
        base.extend ClassMethods
      end
      module ClassMethods
        def recurrence(*); end
      end
    end
  end
end

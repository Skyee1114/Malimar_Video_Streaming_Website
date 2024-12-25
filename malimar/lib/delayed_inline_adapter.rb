module ActiveJob
  module QueueAdapters
    class DelayedInlineAdapter < InlineAdapter
      class << self
        def enqueue_at(job, *_rest)
          enqueue(job)
        end
      end
    end
  end
end

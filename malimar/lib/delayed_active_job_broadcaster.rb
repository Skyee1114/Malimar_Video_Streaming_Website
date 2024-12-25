class DelayedActiveJobBroadcaster < Wisper::ActiveJobBroadcaster
  def broadcast(subscriber, _publisher, event, args)
    delay_opitons = args.extract_options!
    options_tail = delay_opitons.slice! :wait_until, :wait
    args << options_tail unless options_tail.empty?

    Wrapper.set(**delay_opitons).perform_later(subscriber.name, event, args)
  end
end

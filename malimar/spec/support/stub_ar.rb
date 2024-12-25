unless defined? Rails
  User = Module.new
  User::Local = Class.new
  Subscription = Class.new
  Subscription::Free = Class.new
  ActiveRecord = Module.new
  ActiveRecord::RecordNotFound = Class.new StandardError
end

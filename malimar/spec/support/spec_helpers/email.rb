module SpecHelpers
  module Email
    def self.included(base)
      require "email_spec"
      base.include EmailSpec::Helpers
      base.include EmailSpec::Matchers
    end
  end
end

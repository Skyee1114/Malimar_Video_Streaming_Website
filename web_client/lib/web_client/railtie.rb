# frozen_string_literal: true

module WebClient
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/templates.rake"
    end
  end
end

# frozen_string_literal: true

Rails.application.routes.draw do
  ID_CONSTRAINT    = %r{([^/](?!json))+}.freeze unless defined? ID_CONSTRAINT
  UUID_CONSTRAINT  = ID_CONSTRAINT unless defined? UUID_CONSTRAINT
  TOKEN_CONSTRAINT = %r{[^/]+}.freeze unless defined? TOKEN_CONSTRAINT

  root to: "pages#home"
  get "/ping" => "status#index"

  if defined? ActiveAdmin
    constraints id: UUID_CONSTRAINT do
      ActiveAdmin.routes(self)
    end
  end

  mount Sidekiq::Web, at: "/sidekiq" if Rails.env.production?

  namespace :callback do
    resources :payment_notifications, only: :create
    resources :rokupay_notifications, only: :create
  end

  constraints lambda { |request|
    request.format = :json if request.accept.to_s.include? "application/json"
    request.format = :json if request.accept.to_s.include? "application/vnd.api+json"
    request.format == :html
  } do
    # Virtual routes
    get "/account/setup/:token",        constraints: { token: TOKEN_CONSTRAINT },  to: "pages#home",  as: :invitation
    get "/account/edit/(:token)",       constraints: { token: TOKEN_CONSTRAINT },  to: "pages#home",  as: :password
    get "/account/subscribe/(:token)",  constraints: { token: TOKEN_CONSTRAINT },  to: "pages#home",  as: :account
    get "/device/add_channel/step1",                                               to: "pages#home",  as: :add_channel_instruction
    get "(*any)", to: "pages#home", defaults: { format: "html" }
  end

  constraints lambda { |request|
                request.format == :json
              } do
    constraints format: :json do
      resources :dashboards,     only: [:show], controller: "resource/dashboards", defaults: { format: "json" }
      resources :grids,          only: %i[index show], controller: "resource/grids",      defaults: { format: "json" }
      resources :episodes,       only: %i[index show], controller: "resource/episodes",   defaults: { format: "json" }
      resources :shows,          only: [:show], controller: "resource/shows",      defaults: { format: "json" }
      resources :channels,       only: [:show], controller: "resource/channels",   defaults: { format: "json" }
      resources :thumbnails,     only: [:index], controller: "resource/thumbnails", defaults: { format: "json" }

      resources :users,                  only: %i[show create update],   controller: "user/locals",            defaults: { format: "json" },  constraints: { id: UUID_CONSTRAINT }
      resources :invitations,            only: [:create],                controller: "user/invitations",       defaults: { format: "json" }
      resources :passwords,              only: [:create],                controller: "user/passwords",         defaults: { format: "json" }
      resources :sessions,               only: [:create],                controller: "user/sessions",          defaults: { format: "json" }
      resources :permissions,            only: [:index],                 controller: "permissions",            defaults: { format: "json" },  constraints: { id: UUID_CONSTRAINT }
      resources :subscription_payments,  only: [:create],                controller: "subscription_payments",  defaults: { format: "json" }
      resources :devices,                only: %i[index show create],    controller: "devices",                defaults: { format: "json" },  constraints: { id: UUID_CONSTRAINT }
      resources :recently_played,        only: %i[index destroy],        controller: "recently_played",        defaults: { format: "json" },  constraints: { id: UUID_CONSTRAINT }
      resources :favorite_videos,        only: %i[create index destroy], controller: "favorite_videos",        defaults: { format: "json" },  constraints: { id: UUID_CONSTRAINT }

      resources :plans,      only: [:index], defaults: { format: "json" }, constraints: { id: UUID_CONSTRAINT }
      resources :countries,  only: [:index], defaults: { format: "json" }
      resources :states,     only: [:index], defaults: { format: "json" }

      namespace :device do
        resources :activation_requests, only: [:create], defaults: { format: "json" }
      end
    end
  end
end

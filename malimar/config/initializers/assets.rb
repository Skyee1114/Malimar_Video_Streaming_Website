# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "3.1"

# Add additional assets to the asset load path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile =
  %w[*.svg *.eot *.woff *.woff2 *.ttf *.gif *.png *.jpg *.ico *swf] +
  [
    /application\.(css|js)\z/,
    /active_admin\.(js|css)\z/,
    /apitome/,
    %r{/(?!_)[a-z_0-9]+\.html$}
  ]

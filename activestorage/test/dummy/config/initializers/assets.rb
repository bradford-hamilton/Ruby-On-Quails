# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Quails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Quails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Quails.application.config.assets.paths << Quails.root.join("node_modules")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Quails.application.config.assets.precompile += %w( admin.js admin.css )

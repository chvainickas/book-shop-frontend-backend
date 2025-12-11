require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BookShop
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # API mode configuration
    config.api_only = false # Keep false to support Active Storage

    # Add lib directory to autoload paths for JWT helper
    config.eager_load_paths << Rails.root.join("app/lib")

    # Session store configuration for API with cookies
    config.session_store :cookie_store, key: '_book_shop_session'
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use config.session_store, config.session_options

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end

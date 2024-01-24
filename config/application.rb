require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Gramoladisco
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults Rails::VERSION::STRING.to_f

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.active_job.queue_adapter = :sidekiq
    config.autoload_lib(ignore: %w(assets tasks))

    config.generators do |gen|
      gen.assets            false
      gen.helper            false
      # gen.test_framework    :minitest
      gen.jbuilder          true
      gen.orm               :active_record#, primary_key_type: :uuid
      gen.system_tests      false
    end
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.active_storage.variant_processor = :vips
    config.time_zone = 'Europe/Madrid'
    config.i18n.available_locales = %i[es en gl]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = true
  end
end

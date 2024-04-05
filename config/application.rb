require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Alexproduct
  class Application < Rails::Application
    config.load_defaults 7.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += %W(#{config.root}/app)

    # config.active_job.queue_adapter = :delayed_job
    config.active_job.queue_adapter = :sidekiq

    config.i18n.default_locale = :ru
  end
end

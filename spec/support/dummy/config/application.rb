# frozen_string_literal: true
require File.expand_path("../boot", __FILE__)

require "rails"
require "active_job/railtie"
require "action_controller/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require "hubrise_initializer"

module Dummy
  class Application < Rails::Application
    config.root = File.expand_path("../", __dir__)

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults(6.1)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    HubriseInitializer.configure(:logger)
  end
end

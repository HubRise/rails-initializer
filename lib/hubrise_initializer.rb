# frozen_string_literal: true
require "lograge"
require "act-fluent-logger-rails"

require "hubrise_initializer/version"
require "hubrise_initializer/lograge"

class HubriseInitializer
  class << self
    def configure(*initializers)
      initializers.each do |initializer|
        case initializer
        when :logger
          configure_logger
        when :web_console
          configure_web_console
        end
      end
    end

    def lograge_info(controller, details)
      (controller.request.env[LOGRAGE_INFO_ENV] ||= {}).merge!(details)
    end

    private

    def configure_logger
      Rails.application.configure do
        config.lograge.base_controller_class = %w[ActionController::API ActionController::Base]

        if (log_level = ENV["RAILS_LOG_LEVEL"])
          config.log_level = log_level
        end

        case ENV["RAILS_LOGGER"]
        when "stdout"
          # Log to STDOUT (docker-compose)
          config.logger = ActiveSupport::Logger.new(STDOUT)

        when "fluentd"
          # Log to fluentd (kubernetes)
          # ENV['FLUENTD_URL'] is used internally by this logger
          config.logger = ActFluentLoggerRails::Logger.new

          config.lograge.enabled = true
          config.lograge.formatter = ::Lograge::Formatters::Json.new

          config.lograge.ignore_actions = ["HealthCheck::HealthCheckController#index"]
          config.lograge.custom_options = lambda { |event| HubriseInitializer::Lograge.custom_options(event) }
          config.lograge.custom_payload { |controller| HubriseInitializer::Lograge.custom_payload(controller) }

          if ENV["RAILS_LOGRAGE_SQL"] == "true"
            require "lograge/sql"
            require "lograge/sql/extension"
          end

        else # rubocop:disable Style/EmptyElse
          # Log to a file (Rails default)
        end
      end

      if defined?(ActiveJob)
        configure_active_job_logger
      end
    end

    def configure_active_job_logger
      Rails.application.configure do
        ActiveJob::Base.logger = case ENV["RAILS_LOGGER"]
        when "stdout", "fluentd"
          # Do not send ActiveJobs logs to fluentd as this would create new Elasticsearch entries detached from the
          # request.
          ActiveSupport::Logger.new(STDOUT)

        else
          ActiveSupport::Logger.new(File.join(Rails.root, "log", "active_job.log"))
        end
      end
    end

    def configure_web_console
      Rails.application.configure do
        # web_console is generally enabled on dev only
        return unless config.respond_to?(:web_console)

        # - 172.0.0.0/8: host in docker-compose
        # - 192.168.0.0/16: inter containers network in docker-compose
        # - 10.244.0.0/16: pod networks in Kubernetes
        config.web_console.whitelisted_ips = ["172.0.0.0/8", "192.168.0.0/16", "10.0.0.0/8"]
      end
    end
  end

  LOGRAGE_INFO_ENV = "rails-initializer-lograge-info"
end

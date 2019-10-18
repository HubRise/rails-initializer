require 'lograge'
require 'act-fluent-logger-rails'

class HubriseInitializer
  def self.configure(config, *initializers)
    initializers.each do |initializer|
      case initializer
      when :logger
        configure_logger(config)
      when :lograge
        configure_lograge(config)
      when :delayed_job_logger
        configure_delayed_job_logger(config)
      when :web_console
        configure_web_console(config)
      end
    end
  end

  private

  def self.configure_logger(config)
    if log_level = ENV['RAILS_LOG_LEVEL']
      config.log_level = log_level
    end

    case ENV['RAILS_LOGGER']
    when 'stdout'
      # Log to STDOUT (docker-compose)
      config.logger = Logger.new(STDOUT)

    when 'fluentd'
      # Log to fluentd (kubernetes)
      # ENV['FLUENTD_URL'] is used internally by this logger
      config.logger = ActFluentLoggerRails::Logger.new

    else
      # Log to a file (Rails default)
    end
  end

  def self.configure_lograge(config)
    case ENV['RAILS_LOGGER']
    when 'stdout'
      # Log to STDOUT (docker-compose)

    when 'fluentd'
      # Log to fluentd (kubernetes)
      config.lograge.enabled = true
      config.lograge.formatter = Lograge::Formatters::Logstash.new
      config.lograge.formatter = Lograge::Formatters::Json.new

      config.lograge.ignore_actions = ["HealthCheck::HealthCheckController#index"]

      config.lograge.custom_options = lambda do |event|
        exceptions = %w(controller action format id)
        {
            params: event.payload[:params].except(*exceptions),
            # payload: event.payload.inspect,
        }
      end

      config.lograge.custom_payload do |controller|
        {
            release: ENV['RELEASE'],
            host: controller.request.host,
            ip: controller.request.ip,
            user_agent: controller.request.user_agent
        }
      end
    else
      # Log to a file (Rails default)
    end
  end

  def self.configure_delayed_job_logger(config)
    case ENV['RAILS_LOGGER']
    when 'stdout'
      # Log to STDOUT (docker-compose)
      Delayed::Worker.logger = Logger.new(STDOUT)

    when 'fluentd'
      # Log to fluentd (kubernetes)
      # ENV['FLUENTD_URL'] is used internally by this logger
      Delayed::Worker.logger = ActFluentLoggerRails::Logger.new

    else
      # Log to a file
      Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
    end
  end

  def self.configure_web_console(config)
    # web_console is generally enabled on dev only
    return if !config.respond_to?(:web_console)

    # - 172.0.0.0/8: host in docker-compose
    # - 192.168.0.0/16: inter containers network in docker-compose
    # - 10.244.0.0/16: pod networks in Kubernetes
    config.web_console.whitelisted_ips = ['172.0.0.0/8', '192.168.0.0/16', '10.244.0.0/16']
  end
end
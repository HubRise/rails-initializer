# frozen_string_literal: true

module ActFluentLoggerRails
  class LoggerWithOptions
    def self.new(**kwargs)
      Logger.new(kwargs)
    end
  end

  module FluentLoggerExtension
    def initialize(options, level, log_tags)
      super(options, level, log_tags)

      # Rebuild Fluent Logger with custom options
      logger_opts = default_logger_options(options).merge(
        # Keep running when fluent is down
        use_nonblock: true
      )
      @fluent_logger = ::Fluent::Logger::FluentLogger.new(nil, logger_opts)
    end

    private

    # Return same options as the original class
    def default_logger_options(options)
      logger_opts = {
        host: options[:host],
        port: options[:port],
        nanosecond_precision: options[:nanosecond_precision],
      }
      logger_opts[:tls_options] = options[:tls_options] unless options[:tls_options].nil?
      logger_opts
    end
  end
end

ActFluentLoggerRails::FluentLogger.prepend(ActFluentLoggerRails::FluentLoggerExtension)

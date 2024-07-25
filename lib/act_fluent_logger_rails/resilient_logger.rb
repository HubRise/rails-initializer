# frozen_string_literal: true

module ActFluentLoggerRails
  # This logger is a decorator for the original FluentLogger class.
  # It catches any exceptions that occur during the flush method and logs an error to STDOUT.
  module ResilientLogger
    def flush
      super
    rescue Fluent::Logger::FluentError => e
      fallback_to_stdout(e)
    end

    private

    def fallback_to_stdout(error)
      puts "Failed to send logs to Fluentd: #{error.message}"
    end
  end
end

ActFluentLoggerRails::FluentLogger.prepend(ActFluentLoggerRails::ResilientLogger)

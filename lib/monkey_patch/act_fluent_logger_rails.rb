# frozen_string_literal: true

# ----
# We monkey patch this class to pass additional settings to the FluentLogger class.
# ----

module ActFluentLoggerRails
  class FluentLogger
    def initialize(options, level, log_tags)
      self.level = level
      port = options[:port]
      host = options[:host]
      nanosecond_precision = options[:nanosecond_precision]
      @messages_type = (options[:messages_type] || :array).to_sym
      @tag = options[:tag]
      @severity_key = (options[:severity_key] || :severity).to_sym
      @flush_immediately = options[:flush_immediately]
      logger_opts = { host:, port:, nanosecond_precision: }.merge(monkey_patch_settings) # <-- only change here
      logger_opts[:tls_options] = options[:tls_options] unless options[:tls_options].nil?
      @fluent_logger = ::Fluent::Logger::FluentLogger.new(nil, logger_opts)
      @severity = 0
      @log_tags = log_tags
    end

    private

    def monkey_patch_settings
      {
        # AM 25/4/2025: make logging non-blocking so that an ElasticSearch outage does not block the application.
        # See https://docs.google.com/document/d/1fL7PYC2Vb_eqlbUGYWZ7ZvLvX_o821LL1QZxBM_xjXc
        # use_nonblock: true, # default: false  – makes writes non-blocking
        # wait_writeable: true, # default: true   – skip IO.select; drop on EAGAIN
        buffer_overflow_handler: -> (messages) { puts "Buffer overflow: #{messages.size} messages dropped" },
      }
    end
  end
end

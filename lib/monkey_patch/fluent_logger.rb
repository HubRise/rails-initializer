# frozen_string_literal: true

module Fluent
  module Logger
    class FluentLogger
      # CONNECT_TIMEOUT = ENV.fetch("FLUENT_CONNECT_TIMEOUT", 0.3).to_f
      # Monkey-patch the FluentLogger class to add a connection timeout and prevent an outage of fluent from
      # stalling the app (connect timeout is 3 minutes by default).
      # def create_socket!
      #   raise "Option not supported in hubrise_initalizer's monkey patch" if @tls_options || @socket_path
      #
      #   STDERR.puts "[fluent] opening socket to #{@host}:#{@port} (#{CONNECT_TIMEOUT}s timeout)"
      #   @con = Socket.tcp(@host, @port, connect_timeout: CONNECT_TIMEOUT)
      # end

      # def send_data_nonblock(data)
      #   written = @con.write_nonblock(data)
      #   puts "[fluent] sending #{data.bytesize} bytes to #{@host}:#{@port} - written #{written} bytes"
      #   remaining = data.bytesize - written
      #
      #   while remaining > 0
      #     len = @con.write_nonblock(data.byteslice(written, remaining))
      #     remaining -= len
      #     written += len
      #     STDERR.puts "[fluent] remaining bytes: #{remaining} (#{len} written)"
      #   end
      #
      #   written
      # end
    end
  end
end

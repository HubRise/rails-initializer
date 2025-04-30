# frozen_string_literal: true

require "socket"
require "msgpack"
require "timeout"
require "spec_helper"
require "support/dummy_boot"

RSpec.describe("Fluent logging", type: :request) do
  around do |example|
    with_dummy("FLUENTD_URL" => "http://127.0.0.1:24225/test.fluentd?dummy=true",
               "RAILS_LOGGER" => "fluentd") do
      require "rspec/rails"
      example.run
    end
  end

  before(:all) do
    @received_records = []

    @mock_server = TCPServer.new("127.0.0.1", 24225)
    @mock_thread = Thread.new do
      loop do
        client = @mock_server.accept
        unpacker = MessagePack::Factory.new.unpacker(client)

        # Custom ext type (0) → Time object
        unpacker.register_type(0) do |data|
          sec, nsec = data.unpack("NN")
          Time.at(sec, nsec / 1_000.0)
        end

        begin
          unpacker.each { |record| @received_records << record }
        rescue EOFError, IOError, Errno::ECONNRESET
        ensure
          client.close unless client.closed?
        end
      rescue IOError # server closed
        break
      end
    end

    sleep 0.2 # give the server a moment to bind
  end

  after(:all) do
    @mock_server&.close
    @mock_thread&.kill&.join
  end

  it "sends logs to fluentd when calling an endpoint that logs" do
    @received_records.clear

    get("/log_test")
    expect(response).to have_http_status(:ok)

    expected_message = "This is a test log message for Fluentd."
    message_received = false

    Timeout.timeout(3) do
      until message_received
        message_received = @received_records.any? do |record|
          data = record[2]
          data.is_a?(Hash) && Array(data["messages"]).include?(expected_message)
        end
        sleep(0.1) unless message_received
      end
    end

    expect(message_received).to be(true),
                                "Expected log message '#{expected_message}' was not received"
  rescue Timeout::Error
    warn("[fluent_logging_spec] Timeout waiting for log message. Received: #{@received_records.inspect}")
    raise
  end
end

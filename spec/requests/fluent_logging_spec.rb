# frozen_string_literal: true
require "rails_helper"
require "timeout"

RSpec.describe("Fluent logging", type: :request) do
  let(:tcp_mock) { RSpec.configuration.tcp_mock }
  before { tcp_mock.reset! }

  def expect_messages_received(timeout: 1)
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
    loop do
      break if yield(tcp_mock.received_messages)
      if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
        expect(false).to be(true), "Expected messages not received within #{timeout}s.\n" \
          "Received: #{tcp_mock.received_messages.inspect}"
      end
      sleep 0.1
    end
  end

  def expect_no_messages_received(timeout: 1)
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
    loop do
      break if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
      if tcp_mock.received_messages.any?
        expect(tcp_mock.received_messages).to be_empty, "Expected no messages but received: #{tcp_mock.received_messages.inspect}"
        break
      end
      sleep 0.1
    end
  end

  it "sends logs to fluentd when calling an endpoint that logs" do
    get("/fluent_log")
    expect(response).to have_http_status(:ok)

    expect_messages_received do |messages|
      messages.size > 0 && messages[0][2]["messages"][0] == "This is a test log message for Fluentd."
    end
  end

  it "can send long logs to fluentd" do
    get("/fluent_100_logs")
    expect(response).to have_http_status(:ok)

    expect_messages_received do |messages|
      messages.size > 0 && messages[0][2]["messages"].size == 100
    end
  end

  it "can log 10MB of data" do
    get("/fluent_10mb_log")
    expect(response).to have_http_status(:ok)

    expect_messages_received do |messages|
      messages.size == 1
    end
  end

  context "when the Fluent connection drops" do
    it "does not block the Rails request" do
      tcp_mock.drop_connections!

      elapsed = Benchmark.realtime { get("/fluent_log") }
      expect(response).to have_http_status(:ok)
      expect(elapsed).to be < 0.5

      expect_no_messages_received
    end
  end

  context "when Fluent stops consuming but stays connected" do
    it "does not block the Rails request, even for long logs" do
      tcp_mock.pause!

      begin
        Timeout.timeout(1) do
          get("/fluent_10mb_log")
        end
      rescue Timeout::Error
        fail "Request timed out"
      end

      expect(response).to have_http_status(:ok)
      expect_no_messages_received
    end
  end
end

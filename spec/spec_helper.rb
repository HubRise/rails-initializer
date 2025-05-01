# frozen_string_literal: true
require "environment"
require "rubygems"
require "bundler/setup"
require "webmock/rspec"
require "support/mock_tcp_server"

RSpec.configure do |config|
  config.mock_with(:rspec) do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run_when_matching(:focus)
  config.before(:suite) do
    if config.filter.rules.key?(:focus) && ENV["CONTINUOUS_INTEGRATION"] == "true"
      abort("\n🚨 Focused specs detected! Remove all fit, fdescribe, and fcontext before committing.\n\n")
    end
  end

  config.add_setting(:tcp_mock, default: MockTcpServer.new("localhost", 24225))

  config.after(:suite) do
    RSpec.configuration.tcp_mock.shutdown
  end
end

# frozen_string_literal: true
require "environment"
require "rubygems"
require "bundler/setup"
require "webmock/rspec"

RSpec.configure do |config|
  config.mock_with(:rspec) do |mocks|
    mocks.verify_partial_doubles = true
  end
end

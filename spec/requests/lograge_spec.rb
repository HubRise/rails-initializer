require "rails_helper"
require "webmock/rspec"

require_relative "../../lib/hubrise_initializer"

describe HubriseInitializer, type: :request do
  ENV['FLUENTD_URL'] = 'http://fluentd:24224/rails.dummy_app?messages_type=array&severity_key=level'

  class DummyApp < Rails::Application
    HubriseInitializer.configure(:logger)

    # Create a POST /orders action that returns 200 OK
    post "/orders" do
      { status: 200 }.to_json
    end
  end

  describe "when we send a POST request to DummyApp" do
    let!(:fluentd_stub) { stub_request(:post, ENV['FLUENTD_URL']) }

    it "calls the logger" do
      # Expect fluentd_stub to have been called once
      expect(fluentd_stub).to have_been_requested.once
      post "/orders"
    end
  end
end

# frozen_string_literal: true
require "rails_helper"
require "fluent-logger"

describe HubriseInitializer, type: :request do
  let!(:fluent_logger) do
    fluent_logger = double
    allow(fluent_logger).to receive(:post)

    # Create a write accessor for ActFluentLoggerRails::FluentLogger.@fluent_logger to plug our double.
    ActFluentLoggerRails::FluentLogger.class_eval do
      attr_accessor :fluent_logger
    end

    Rails.application.config.logger.fluent_logger = fluent_logger
    fluent_logger
  end

  let(:expected_level) { "INFO" }

  RSpec.shared_examples("sends expected_message with expected_level to fluentd") do
    it "calls #info on the logger" do
      expect(Rails.application.config.logger).to receive(:info).with(-> (message) do
        parsed_message = JSON.parse(message)
        expect(parsed_message).to include(expected_message)
      end)
      subject
    end

    it "calls fluent_logger.post" do
      expect(fluent_logger).to receive(:post).with("rails.dummy", -> (map) do
        expect(map[:severity]).to eq(expected_level)
        expect(map[:messages].size).to eq(1)
        parsed_message = JSON.parse(map[:messages].first)
        expect(parsed_message).to include(expected_message)
      end)
      subject
    end
  end

  it "sets config.lograge.enabled to true" do
    expect(Rails.application.config.lograge.enabled).to be_truthy
  end

  describe "when the action responds 200" do
    subject { post("/ok?foo=fooX", params: { body: "bodyX" }, headers: { "X-Access-Token" => "accessTokenX" }) }

    it "responds 200" do
      subject
      expect(response).to have_http_status(200)
    end

    let(:expected_message) do
      {
        "method" => "POST",
        "path" => "/ok",
        "controller" => "ApplicationController",
        "release" => "9.9.9",
        "host" => "www.example.com",
        "params" => "foo=fooX",
        "access_token" => "accessTokenX",
        "account_name" => "accountNameX",
        "account_id" => "accountIdX",
        "request_body" => "body=bodyX",
        "response_body" => { result: "All good!" }.to_json,
      }
    end

    include_examples "sends expected_message with expected_level to fluentd"
  end

  describe "when the body is not UTF-8 encoded" do
    subject { get("/image") }

    it "responds 200" do
      subject
      expect(response).to have_http_status(200)
    end

    let(:expected_message) do
      {
        "response_body" => a_string_matching(/Binary \(\d* bytes\)/),
      }
    end

    include_examples "sends expected_message with expected_level to fluentd"
  end

  describe "when the action does not exist" do
    subject { get("/invalid_url") }

    it "responds 404" do
      subject
      expect(response).to have_http_status(404)
    end

    let(:expected_message) do
      {
        "method" => "GET",
        "path" => "/invalid_url",
        "response_body" => nil,
      }
    end

    include_examples "sends expected_message with expected_level to fluentd"
  end
end

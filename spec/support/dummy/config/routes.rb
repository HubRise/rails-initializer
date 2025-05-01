# frozen_string_literal: true

Rails.application.routes.draw do
  post "/ok" => "application#ok"
  get "/image" => "application#image"
  get "/invalid_url" => "application#invalid_url"
  get "/fluent_log" => "application#fluent_log"
  get "/fluent_100_logs" => "application#fluent_100_logs"
  get "/fluent_10mb_log" => "application#fluent_10mb_log"
end

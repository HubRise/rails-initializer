# frozen_string_literal: true

Rails.application.routes.draw do
  post "/ok" => "application#ok"
  get "/invalid_url" => "application#invalid_url"
end

# frozen_string_literal: true
class ApplicationController < ActionController::Base
  def ok
    render(json: { result: "All good!" }, status: 200)
  end

  def invalid_url
    head(404)
  end
end

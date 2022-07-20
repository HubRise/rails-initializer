# frozen_string_literal: true
class ApplicationController < ActionController::Base
  before_action :lograge_info, only: [:ok]

  def ok
    render(json: { result: "All good!" }, status: 200)
  end

  def invalid_url
    head(404)
  end

  protected

  def lograge_info
    HubriseInitializer.lograge_info(self, {
      access_token: request.headers["X-Access-Token"],
      account_name: "accountNameX",
      account_id: "accountIdX",
    })
  end
end

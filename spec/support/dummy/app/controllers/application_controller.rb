# frozen_string_literal: true
class ApplicationController < ActionController::Base
  before_action :lograge_info, only: [:ok]

  def ok
    render(json: { result: "All good!" }, status: 200)
  end

  def image
    send_file(
      Rails.root.join("app", "assets", "monster.png"),
      type: "image/jpeg",
      disposition: "inline",
    )
  end

  def invalid_url
    head(404)
  end

  def log_test
    Rails.logger.info("This is a test log message for Fluentd.")
    render(plain: "Logged!")
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

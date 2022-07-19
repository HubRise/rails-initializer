# frozen_string_literal: true
ENV["RAILS_ENV"] = "test"
ENV["FLUENTD_URL"] = "http://www.example.com/rails.dummy?messages_type=array&severity_key=level"
ENV["RAILS_LOGGER"] = "fluentd"
ENV["RELEASE"] = "9.9.9"
ENV["RAILS_LOGRAGE_QUERY"] = "true"

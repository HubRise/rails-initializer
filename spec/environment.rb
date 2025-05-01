# frozen_string_literal: true
ENV["RAILS_ENV"] = "test"
ENV["FLUENTD_URL"] = "http://127.0.0.1:24225/test.fluentd?messages_type=array&severity_key=level"
ENV["RAILS_LOGGER"] = "fluentd"
ENV["RELEASE"] = "9.9.9"
ENV["RAILS_LOGRAGE_QUERY"] = "true"

# frozen_string_literal: true
class HubriseInitializer
  class Lograge
    class << self
      def custom_options(_event)
        {}
      end

      def custom_payload(controller)
        request = controller.request
        response = controller.response
        {
          release: ENV["RELEASE"],
          host: request.host,
          ip: request.ip,
          user_agent: request.user_agent,
          params: request.query_string.presence,
        }.merge(
          if ENV["RAILS_LOGRAGE_QUERY"] == "true"
            {
              request_headers: process_request_headers(request).to_s,
              request_body: truncate_body(switch_to_utf8(request.raw_post)),
              response_headers: response.headers.to_h.to_s,
              response_body: truncate_body(switch_to_utf8(response.body)),
            }
          else
            {}
          end
        )
      end

      private

      TRUNCATED_BODY_MAX_LENGTH = 1000

      # Attempt to switch string encoding to utf-8. Return fallback if not a valid utf-8 sequence.
      def switch_to_utf8(s)
        return unless s

        return s if s.encoding == Encoding::UTF_8

        s_utf_8 = s.dup.force_encoding(Encoding::UTF_8)
        return s_utf_8 if s_utf_8.valid_encoding?

        # Fallback for binary data
        "Binary (#{s.size} bytes)"
      end

      def truncate_body(s)
        s.present? ? s.squish.truncate(TRUNCATED_BODY_MAX_LENGTH, omission: "...") : nil
      end

      def process_request_headers(request)
        http_prefix = "HTTP_"
        request.headers.each_with_object({}) do |(key, value), hash|
          next hash unless key.start_with?(http_prefix)

          header_name = key.gsub(http_prefix, "").split("_").map(&:capitalize).join("-")
          hash[header_name] = value
        end
      end
    end
  end
end

module Whiplash
  module App
    module Signing

      def request_body(body)
        body.blank? ? ENV["WHIPLASH_CLIENT_ID"] : body
      end

      def signature(body)
        sha256 = OpenSSL::Digest::SHA256.new
        OpenSSL::HMAC.hexdigest(sha256,
          ENV["WHIPLASH_CLIENT_SECRET"], request_body(body))
      end

      def verified?(request)
        body = request.try(:body).try(:read)
        request.headers["X-WHIPLASH-SIGNATURE"] == signature(body)
      end

    end
  end
end

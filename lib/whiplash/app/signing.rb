module Whiplash
  class App
    module Signing
      def signature(body)
        sha256 = OpenSSL::Digest::SHA256.new
        OpenSSL::HMAC.hexdigest(sha256,
          ENV["WHIPLASH_CLIENT_SECRET"], request_body(body))
      end

      def verified?(request)
        body = request.try(:body).try(:read)
        request.headers["X-WHIPLASH-SIGNATURE"] == signature(body)
      end

      private

      def request_body(body)
        begin
          (body.nil? || body.empty?) ? ENV["WHIPLASH_CLIENT_ID"] : body
        rescue NoMethodError => e
          ENV["WHIPLASH_CLIENT_ID"]
        end
      end
    end
  end
end

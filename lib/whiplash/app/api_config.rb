module Whiplash
  class App
    module ApiConfig

      def api_url
        if defined?(Rails)
          %w(development test).include?(Rails.env.to_s) ? testing_url : production_url
        else
          ENV["WHIPLASH_API_URL"]
        end
      end

      def production_url
        ENV["WHIPLASH_API_URL"] || "https://www.getwhiplash.com"
      end

      def testing_url
        ENV["WHIPLASH_API_URL"] || "https://sandbox.getwhiplash.com"
      end

    end
  end
end

module Whiplash
  module App
    module ApiConfig

      def api_url
        if defined?(Rails)
          %w(development testing).include?(Rails.env.to_s) ? testing_url : production_url
        else
          ENV["WHIPLASH_API_URL"]
        end
      end

      def production_url
        ENV["WHIPLASH_API_URL"] || "https://www.whiplashmerch.com"
      end

      def testing_url
        ENV["WHIPLASH_API_URL"] || "https://testing.whiplashmerch.com"
      end

    end
  end
end

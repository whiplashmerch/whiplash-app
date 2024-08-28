require "whiplash/app/api_config"
require "whiplash/app/caching"
require "whiplash/app/connections"
require "whiplash/app/finder_methods"
require "whiplash/app/signing"
require "whiplash/app/version"
require "oauth2"


module Whiplash

  module App
    class << self
      include Whiplash::App::ApiConfig
      include Whiplash::App::Caching
      include Whiplash::App::Connections
      include Whiplash::App::FinderMethods
      include Whiplash::App::Signing

      attr_accessor :customer_id, :shop_id

      def client
        OAuth2::Client.new(ENV["WHIPLASH_CLIENT_ID"], ENV["WHIPLASH_CLIENT_SECRET"], site: api_url)
      end

      def connection(version = "api/v2")
        out = Faraday.new(url: [api_url, version].join("/")) do |conn|
          conn.request :authorization, 'Bearer', token
          conn.request :json # Automatically encode requests as JSON
          conn.response :json # Automatically parse responses as JSON
          conn.response :raise_error # Raise exceptions for 4xx and 5xx responses
          conn.adapter Faraday.default_adapter # Use the default adapter (Net::HTTP)
        end
        return out
      end

      def refresh_token!
        oauth_token = client.client_credentials.get_token(scope: ENV["WHIPLASH_CLIENT_SCOPE"])
        new_token = oauth_token.token
        cache_store["whiplash_api_token"] = new_token
      end

      def token
        refresh_token! unless cache_store["whiplash_api_token"]
        return cache_store["whiplash_api_token"]
      end
    end
  end
end

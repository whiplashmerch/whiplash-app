require "whiplash/app/api_config"
require "whiplash/app/caching"
require "whiplash/app/connections"
require "whiplash/app/finder_methods"
require "whiplash/app/signing"
require "whiplash/app/version"
require "oauth2"
require "faraday_middleware"

module Whiplash

  module App
    class << self
      include Whiplash::App::ApiConfig
      include Whiplash::App::Caching
      include Whiplash::App::Connections
      include Whiplash::App::FinderMethods
      include Whiplash::App::Signing

      attr_accessor :customer_id, :shop_id, :token

      def client
        OAuth2::Client.new(ENV["WHIPLASH_CLIENT_ID"], ENV["WHIPLASH_CLIENT_SECRET"], site: api_url)
      end

      def connection
        token = refresh_token! if token_expired?
        out = Faraday.new [api_url, "api/v2"].join("/") do |conn|
          conn.request :oauth2, token, token_type: "bearer"
          conn.request :json
          conn.response :json, :content_type => /\bjson$/
          conn.use :instrumentation
          conn.adapter Faraday.default_adapter
        end
        return out
      end

      def token=(oauth_token)
        oauth_token = OAuth2::AccessToken.from_hash(client, oauth_token) unless oauth_token.is_a?(OAuth2::AccessToken)
        super(oauth_token)
      end

      def refresh_token!
        if token.blank? # If we're storing locally, grab a new token and cache it
          access_token = client.client_credentials.get_token(scope: ENV["WHIPLASH_CLIENT_SCOPE"])
          new_token = access_token.to_hash
          cache_store["whiplash_api_token"] = new_token
          access_token
        else
          token.refresh!
        end
      end

      def token_expired?
        return token.expired? unless token.blank?
        return true unless cache_store.has_key?("whiplash_api_token")
        return true if cache_store["whiplash_api_token"].blank?
        false
      end

    end
  end
end

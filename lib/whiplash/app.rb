require "whiplash/app/api_config"
require "whiplash/app/connections"
require "whiplash/app/version"
require "whiplash/app/connections"
require "whiplash/app/signing"
require "whiplash/app/version"
require "oauth2"
require "faraday_middleware"
require "moneta"

module Whiplash

  module App
    class << self
      include Whiplash::App::Connections
      include Whiplash::App::ApiConfig
      include Whiplash::App::Signing
      attr_accessor :customer_id, :shop_id

      def cache_store
        if ENV["REDIS_HOST"]
          Moneta.new(:Redis, host: ENV["REDIS_HOST"], port: ENV["REDIS_PORT"], PASSWORD: ENV["REDIS_PASSWORD"])
        else
          Moneta.new(:File, dir: "tmp", expires: true)
        end
      end

      def client
        OAuth2::Client.new(ENV["WHIPLASH_CLIENT_ID"], ENV["WHIPLASH_CLIENT_SECRET"], site: api_url)
      end

      def connection
        out = Faraday.new [api_url, "api/v2"].join("/") do |conn|
          conn.request :oauth2, token
          conn.request :json
          conn.response :json, :content_type => /\bjson$/
          conn.use :instrumentation
          conn.adapter Faraday.default_adapter
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

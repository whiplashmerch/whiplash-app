require "whiplash/app/api_config"
require "whiplash/app/caching"
require "whiplash/app/connections"
require "whiplash/app/finder_methods"
require "whiplash/app/signing"
require "whiplash/app/version"
require "oauth2"
require "faraday_middleware"

module Whiplash
  class App
    include Whiplash::App::ApiConfig
    include Whiplash::App::Caching
    include Whiplash::App::Connections
    include Whiplash::App::FinderMethods
    extend Whiplash::App::Signing

    attr_accessor :customer_id, :shop_id, :token

    def initialize(token=nil, options={})
      opts = options.with_indifferent_access
      @token = format_token(token) unless token.nil?
      @customer_id = options[:customer_id]
      @shop_id = options[:shop_id]
    end

    def client
      OAuth2::Client.new(ENV["WHIPLASH_CLIENT_ID"], ENV["WHIPLASH_CLIENT_SECRET"], site: api_url)
    end

    def connection
      out = Faraday.new [api_url, "api/v2"].join("/") do |conn|
        conn.request :oauth2, token.token, token_type: "bearer"
        conn.request :json
        conn.response :json, :content_type => /\bjson$/
        conn.use :instrumentation
        conn.adapter Faraday.default_adapter
      end
      return out
    end

    def token=(oauth_token)
      instance_variable_set("@token", format_token(oauth_token))
    end

    def refresh_token!
      if token.blank? # If we're storing locally, grab a new token and cache it
        access_token = client.client_credentials.get_token(scope: ENV["WHIPLASH_CLIENT_SCOPE"])
        new_token = access_token.to_hash
        cache_store["whiplash_api_token"] = new_token
      else
        access_token = token.refresh!
      end
      self.token = access_token
    end

    def token_expired?
      return token.expired? unless token.blank?
      return true unless cache_store.has_key?("whiplash_api_token")
      return true if cache_store["whiplash_api_token"].blank?
      false
    end

    private
    def format_token(oauth_token)
      unless oauth_token.is_a?(OAuth2::AccessToken)
        raise StandardError, "Token must either be a Hash or an OAuth2::AccessToken" unless oauth_token.is_a?(Hash)
        oauth_token['expires'] = oauth_token['expires'].to_s # from_hash expects 'true'
        if oauth_token.has_key?('token')
          oauth_token['access_token'] = oauth_token['token']
          oauth_token.delete('token')
        end
        oauth_token = OAuth2::AccessToken.from_hash(client, oauth_token)
      end
    end

  end
end

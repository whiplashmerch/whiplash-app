require "whiplash/app/api_config"
require "whiplash/app/connections"
require "whiplash/app/finder_methods"
require "whiplash/app/signing"
require "whiplash/app/version"
require "errors/whiplash_api_error"
require "oauth2"
require "faraday"

# Rails app stuff
if defined?(Rails::Railtie)
  require "whiplash/app/railtie"
  require "whiplash/app/canonical_host" 
  require "whiplash/app/controller_helpers"
end 

module Whiplash
  class App
    extend Whiplash::App::Signing
    extend Whiplash::App::ApiConfig
    include Whiplash::App::Connections
    include Whiplash::App::FinderMethods

    attr_accessor :customer_id, :shop_id, :token

    def initialize(token, options={})
      @token = format_token(token)
      @customer_id = options[:customer_id]
      @shop_id = options[:shop_id]
      @api_version = options[:api_version] || 2 # can be 2_1
    end

    def versioned_api_url
      "api/v#{@api_version}"
    end

    def client
      OAuth2::Client.new(ENV["WHIPLASH_CLIENT_ID"], ENV["WHIPLASH_CLIENT_SECRET"], site: self.class.api_url)
    end

    def connection
      Faraday.new [self.class.api_url, versioned_api_url].join("/") do |conn|
        # Authentication
        conn.request :authorization, 'Bearer', token.token
        conn.request :json
        conn.response :json, :content_type => /\bjson$/
        conn.options.timeout = 30 # Total request timeout
        conn.options.open_timeout = 5 # Connection establishment timeout
        
        # Use persistent HTTP connections (requires net-http-persistent gem)
        begin
          conn.adapter :net_http_persistent
        rescue LoadError
          # Fallback to default adapter if net-http-persistent isn't available
          Rails.logger.warn "[WhiplashApp] net-http-persistent gem not found, using default adapter" if defined?(Rails)
          conn.adapter Faraday.default_adapter
        end
      end
    end

    def token=(oauth_token)
      instance_variable_set("@token", format_token(oauth_token))
    end

    def refresh_token!
      case ENV["WHIPLASH_CLIENT_SCOPE"]
      when /app_(manage|read)/
        begin
          access_token = self.class.client_credentials_token
        rescue URI::InvalidURIError => e
          raise StandardError, "The provided URL (#{ENV["WHIPLASH_API_URL"]}) is not valid"
        end
      else
        raise StandardError, "You must request an access token before you can refresh it" if token.nil?
        raise StandardError, "Token must either be a Hash or an OAuth2::AccessToken" unless token.is_a?(OAuth2::AccessToken)
        access_token = token.refresh!
      end
      self.token = access_token
    end

    def token_expired?
      return token.expired? unless token.nil?
      false
    end

    class << self 
      def client_credentials_token
        client = OAuth2::Client.new(ENV["WHIPLASH_CLIENT_ID"], ENV["WHIPLASH_CLIENT_SECRET"], site: api_url)
        client.client_credentials.get_token(scope: ENV["WHIPLASH_CLIENT_SCOPE"])
      end
    end

    private
    def format_token(oauth_token)
      return oauth_token if oauth_token.is_a?(OAuth2::AccessToken)
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

module Net
  class HTTPResponse
    class << self
      private

      def read_status_line(sock)
        str = sock.readline
        og = str.dup
        str.gsub!(/.*?(?=HTTP)/im, "")
        if og.size > str.size
          Rails.logger.warn "[WhiplashApp] Failed to read header status for #{og.inspect}"
        end
        m = /\AHTTP(?:\/(\d+\.\d+))?\s+(\d\d\d)(?:\s+(.*))?\z/in.match(str) or
          raise Net::HTTPBadResponse, "wrong status line: #{str.dump}"
        m.captures
      end

    end
  end
end

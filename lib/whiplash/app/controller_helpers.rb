# frozen_string_literal: true
module Whiplash
  class App
    module ControllerHelpers
      extend ActiveSupport::Concern

      included do
        helper_method :cookie_domain,
                      :core_url,
                      :core_url_for,
                      :current_customer,
                      :current_user,
                      :current_warehouse
      end 

      private

      def application_domain
        return nil if Rails.configuration.application_url.blank?
        host = URI.parse(Rails.configuration.application_url).host
        '.' + host
      end

      def clear_application_cookies!
        return if application_domain.blank?
        cookie_keys_we_care_about.each { |k| cookies.delete(k, domain: application_domain) }
      end

      def clear_domain_cookies!
        cookie_keys_we_care_about.each { |k| cookies.delete(k, domain: cookie_domain) }
      end

      def cookie_domain
        host = URI.parse(core_url).host
        host.gsub!('www.', '')
        '.' + host
      end

      def cookie_keys_we_care_about
        %i(
            _session
            customer
            customer_id
            oauth_token
            partner_id 
            user
            user_id
            warehouse
            warehouse_id
          )
      end

      def core_url
        ENV['WHIPLASH_CORE_URL'] || ENV['WHIPLASH_API_URL']
      end

      def core_url_for(path, query_params = {})
        out = [core_url, path].join('/')
        out = [out, query_params.to_query].join('?') if query_params.present?
        return out
      end

      def current_customer
        return if cookies[:customer].blank?
        begin
          customer_hash = JSON.parse(cookies[:customer])
          @current_customer ||= customer_hash
        rescue StandardError => e 
          Rails.logger.warn "Customer could not be initialized: #{e.message}"
          nil
        end
      end

      def current_customer_full
        return if cookies[:customer].blank?
        begin
          customer_hash = JSON.parse(cookies[:customer])
          @current_customer ||= @whiplash_api.get!("customers/#{customer_hash['id']}").body
        rescue StandardError => e 
          Rails.logger.warn "Customer could not be initialized: #{e.message}"
          nil
        end
      end

      def current_user
        return if cookies[:user].blank?
        begin
          @current_user ||= JSON.parse(cookies[:user])
        rescue StandardError => e 
          Rails.logger.warn "User could not be initialized: #{e.message}"
          @current_user = nil
        end
      end

      def current_warehouse
        return if cookies[:warehouse].blank?
        begin
          warehouse_hash = JSON.parse(cookies[:warehouse])
          @current_warehouse ||= warehouse_hash
        rescue StandardError => e 
          Rails.logger.warn "Warehouse could not be initialized: #{e.message}"
          @current_warehouse = nil
        end
      end

      def current_warehouse_full
        return if cookies[:warehouse].blank?
        begin
          warehouse_hash = JSON.parse(cookies[:warehouse])
          @whiplash_api.get!("warehouses/#{warehouse_hash['id']}").body
        rescue StandardError => e 
          Rails.logger.warn "Warehouse could not be initialized: #{e.message}"
          nil
        end
      end

      def http_scheme
        URI(core_url).scheme
      end

      def init_whiplash_api(options = {})
        if cookies[:oauth_token].blank?
          clear_application_cookies!
          return redirect_to core_url_for('login', redirect_url: request.original_url)
        end
        token = {access_token: cookies[:oauth_token]}
        begin 
          @whiplash_api = Whiplash::App.new(token, options)
        rescue StandardError => e 
          Rails.logger.warn "API failed to initialize: #{e.message}"
          @whiplash_api = nil
        end
      end
    
      def require_user
        return if current_user.present?
        clear_application_cookies!
        redirect_to core_url_for('login', redirect_url: request.original_url) 
      end
    
      def set_locale!
        I18n.default_locale = :en
        I18n.locale = current_user.try('locale') || I18n.default_locale
      end

      def set_current_customer_cookie!(customer_id, expires_at = nil)
        customer = @whiplash_api.get!("customers/#{customer_id}").body
        user = @whiplash_api.get!("me").body
        fields_we_care_about = %w(id name)
        customer_hash = customer.slice(*fields_we_care_about)
        expires_at ||= user['current_sign_in_expires_at']

        shared_values = {
          expires: DateTime.parse(expires_at),
          secure: http_scheme == 'https',
          samesite: :strict,
          domain: cookie_domain
        }
        cookies[:customer] = shared_values.merge(value: customer_hash.to_json)
      end

      def set_current_user_cookie!(expires_at = nil)
        user = @whiplash_api.get!("me").body
        fields_we_care_about = %w(id email role locale first_name last_name partner_id customer_ids)
        user_hash = user.slice(*fields_we_care_about)
        expires_at ||= user['current_sign_in_expires_at']

        shared_values = {
          expires: DateTime.parse(expires_at),
          secure: http_scheme == 'https',
          samesite: :strict,
          domain: cookie_domain
        }
        cookies[:user] = shared_values.merge(value: user_hash.to_json)
      end

      def set_current_warehouse_cookie!(warehouse_id, expires_at = nil)
        warehouse = @whiplash_api.get!("warehouses/#{warehouse_id}").body
        user = @whiplash_api.get!("me").body
        fields_we_care_about = %w(id name slug)
        warehouse_hash = warehouse.slice(*fields_we_care_about)
        expires_at ||= user['current_sign_in_expires_at']

        shared_values = {
          expires: DateTime.parse(expires_at),
          secure: http_scheme == 'https',
          samesite: :strict,
          domain: cookie_domain
        }
        cookies[:warehouse] = shared_values.merge(value: warehouse_hash.to_json)
      end

      def unset_current_customer_cookie!
        cookies.delete(:customer, domain: cookie_domain)
      end

      def unset_current_warehouse_cookie!
        cookies.delete(:warehouse, domain: cookie_domain)
      end

    end
  end
end
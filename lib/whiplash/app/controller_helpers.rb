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

      def cookie_domain
        '.' + URI.parse(core_url).host
      end

      def core_url
        ENV['WHIPLASH_CORE_URL'] || ENV['WHIPLASH_API_URL']
      end

      def core_url_for(path)
        [core_url, path].join('/')
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
        return redirect_to core_url_for('login') if cookies[:oauth_token].blank?
        token = {access_token: cookies[:oauth_token]}
        begin 
          @whiplash_api = Whiplash::App.new(token, options)
        rescue StandardError => e 
          Rails.logger.warn "API failed to initialize: #{e.message}"
          @whiplash_api = nil
        end
      end
    
      def require_user
        redirect_to core_url_for('login') if current_user.blank?
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
        fields_we_care_about = %w(id name)
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
# frozen_string_literal: true
module Whiplash
  class App
    module CanonicalHost
      extend ActiveSupport::Concern

      private

      def require_canonical_host!
        canonical_host = ENV.fetch('CANONICAL_HOST', false).in?([true, 'true', 1, '1'])
        return unless canonical_host
        application_host = URI.parse(Rails.configuration.app_url).host
        return if application_host == request.host
        return unless request.method_symbol == :get # can't redirect PUT, POST, DELETE
    
        redirect_to_canonical_host request.query_parameters
      end
    
      def redirect_to_canonical_host(query_params, status=301)
        redirect_to "#{Rails.configuration.app_url}#{request.path}#{'?' if query_params.to_query.present?}#{query_params.to_query}", status: status
      end

    end
  end
end
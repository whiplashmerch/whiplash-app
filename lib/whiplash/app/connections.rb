module Whiplash
  module App
    module Connections
      PER_PAGE_REQUEST_LIMIT = 50

      def app_request(options = {})
        if options[:params][:id]
          endpoint = [options[:endpoint], options[:params].delete(:id)].join('/')
        else
          endpoint = options[:endpoint]
        end

        if options.dig(:options, :version)
          version = options.dig(:options, :version)
        else
          version = "api/v2"
        end

        connection(version).send(options[:method],
                                 endpoint,
                                 options[:params],
                                 sanitize_headers(options[:headers]))
      end

      def multi_page_get!(endpoint, params = {}, headers = nil)
        results = []
        page = 1
        params[:per_page] = PER_PAGE_REQUEST_LIMIT

        loop do
          partial_results_request = app_request!(
            method: :get,
            endpoint: endpoint,
            params: params,
            headers: headers
          ).body

          results << partial_results_request
          results.flatten!

          page += 1
          params[:page] = page

          break if partial_results_request.size == 0
          break if partial_results_request.size < PER_PAGE_REQUEST_LIMIT
        end

        results
      end

      def delete(endpoint, params = {}, headers = nil, options = {})
        app_request(method: :delete,
                    endpoint: endpoint,
                    params: params,
                    headers: headers,
                    options: options
                   )
      end

      def get(endpoint, params = {}, headers = nil, options = {})
        app_request(method: :get,
                    endpoint: endpoint,
                    params: params,
                    headers: headers,
                    options: options
                   )
      end

      def post(endpoint, params = {}, headers = nil, options = {})
        app_request(method: :post,
                    endpoint: endpoint,
                    params: params,
                    headers: headers,
                    options: options
                   )
      end

      def put(endpoint, params = {}, headers = nil, options = {})
        app_request(method: :put,
                    endpoint: endpoint,
                    params: params,
                    headers: headers,
                    options: options
                   )
      end

      def sanitize_headers(headers)
        if headers
          {}.tap do |hash|
            headers.each do |k,v|
              hash["X-#{k.to_s.upcase.gsub('_','-')}"] = v.to_s
            end
          end
        end
      end

    end
  end
end

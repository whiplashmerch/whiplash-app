module Whiplash
  module App
    module Connections

      def app_request(options = {})
        if options[:params][:id]
          endpoint = [options[:endpoint], options[:params].delete(:id)].join('/')
        else
          endpoint = options[:endpoint]
        end
        connection.send(options[:method],
                        endpoint,
                        options[:params],
                        sanitize_headers(options[:headers]))
      end

      def delete(endpoint, params = {}, headers = nil)
        app_request(method: :delete,
                    endpoint: endpoint,
                    params: params,
                    headers: headers)
      end

      def get(endpoint, params = {}, headers = nil)
        app_request(method: :get,
                    endpoint: endpoint,
                    params: params,
                    headers: headers)
      end

      def post(endpoint, params = {}, headers = nil)
        app_request(method: :post,
                    endpoint: endpoint,
                    params: params,
                    headers: headers)
      end

      def put(endpoint, params = {}, headers = nil)
        app_request(method: :put,
                    endpoint: endpoint,
                    params: params,
                    headers: headers)
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

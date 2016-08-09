module Whiplash
  module App
    module Connections

      def app_request(options = {})
        connection.send(options[:method],
                        options[:endpoint],
                        options[:params],
                        sanitize_headers(options[:headers]))
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

require "moneta"
require "whiplash/app/moneta/namespace"
module Whiplash
  module App
    module Caching

      def cache_store
        if ENV["REDIS_HOST"]
          store = Moneta.new(:Redis, host: ENV["REDIS_HOST"], port: ENV["REDIS_PORT"], PASSWORD: ENV["REDIS_PASSWORD"], expires: 2.hours)
          Moneta::Namespace.new store, namespace_value
        else
          Moneta.new(:File, dir: "tmp", expires: 2.hours)
        end
      end

      def namespace_value
        ENV["REDIS_NAMESPACE"] || ENV["WHIPLASH_CLIENT_ID"]
      end

    end
  end
end

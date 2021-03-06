require "moneta"
require "whiplash/app/moneta/namespace"
module Whiplash
  class App
    module Caching

      def cache_store
        if ENV["REDIS_HOST"]
          store = Moneta.new(:Redis, host: ENV["REDIS_HOST"], port: ENV["REDIS_PORT"], password: ENV["REDIS_PASSWORD"], expires: 7200)
          Moneta::Namespace.new store, Whiplash::App::Caching.namespace_value
        else
          Moneta.new(:File, dir: "tmp", expires: 7200)
        end
      end

      def self.namespace_value
        ENV["REDIS_NAMESPACE"] || ENV["WHIPLASH_CLIENT_ID"]
      end

    end
  end
end

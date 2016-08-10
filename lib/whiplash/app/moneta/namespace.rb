module Moneta
  class Namespace
    attr_reader :moneta_store

    def initialize store, ns
      @moneta_store, @ns = store, ns
    end

    def [] key
      @moneta_store["#{@ns}:#{key}"]
    end

    def []= key, value
      @moneta_store["#{@ns}:#{key}"] = value
    end

    def delete key
      @moneta_store.delete "#{@ns}:#{key}"
    end

    def key? key
      @moneta_store.key? "#{@ns}:#{key}"
    end

    def has_key? key
      @moneta_store.has_key? "#{@ns}:#{key}"
    end

    def store key, value, options
      @moneta_store.store "#{@ns}:#{key}", value, options
    end

    def update_key key, options
      @moneta_store.update_key "#{@ns}:#{key}", options
    end

    def clear
      @moneta_store.clear
    end

    def method_missing method, args
      @moneta_store.call method, *args
    end
  end
end

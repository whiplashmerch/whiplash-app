module Whiplash
  module App
    module FinderMethods

      def find_all(resource, headers = nil)
        get("#{resource}", {}, headers)
      end

      def create(resource, params, headers = nil)
        post("#{resource}", params, headers)
      end

      def destroy(resource, id, headers = nil)
        delete("#{resource}", { id: id }, headers)
      end

      def find(resource, id, headers = nil)
        get("#{resource}", { id: id }, headers)
      end

      def update(resource, id, params = {}, headers = nil)
        put("#{resource}", { id: id }, params, headers)
      end
    end
  end
end

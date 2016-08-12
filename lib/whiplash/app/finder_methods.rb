module Whiplash
  module App
    module FinderMethods

      def count(resource, params = {}, headers = nil)
        get("#{resource}/count", params, headers)["count"]
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

      def find_all(resource, params = {}, headers = nil)
        get("#{resource}", params, headers)
      end

      def update(resource, id, params = {}, headers = nil)
        put("#{resource}", params.merge(id: id), headers)
      end
    end
  end
end

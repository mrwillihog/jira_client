module JiraClient
  module API
    module Utils

    private

      def objects_from_response(klass, request_method, path, options={})
        response = send(request_method.to_sym, path, options)
        objects_from_array(klass, response)
      end

      def objects_from_array(klass, array)
        array.map do |element|
          klass.from_response(element)
        end
      end

      def object_from_response(klass, request_method, path, options={})
        response = send(request_method.to_sym, path, options)
        klass.from_response(response)
      end

    end
  end
end

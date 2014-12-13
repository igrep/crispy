module Crispy
  module CrispyInternal
    class Stubber < Module
      public :prepend_features

      def initialize stubs_map = {}
        super()
        stub stubs_map
      end

      def reinitialize stubs_map = {}
        remove_method(*self.instance_methods(false))
        stub stubs_map
      end

      NOT_SPECIFIED = ::Object.new

      def stub method_name_or_hash, returned_value = NOT_SPECIFIED, &definition
        case method_name_or_hash
        when Hash
          hash = method_name_or_hash
          hash.each do|method_name, value|
            stub method_name, value
          end
        when ::Symbol, ::String
          self.module_exec method_name_or_hash do|method_name|
            # TODO: should not ignore arguments?
            define_method(method_name) {|*_arguments| returned_value }
          end
        end
        self
      end

    end
  end
end

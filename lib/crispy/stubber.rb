module Crispy
  class Stubber < Module

    def initialize stubs_map = {}
      super()
      stub stubs_map
    end

    def prepend_stubbed_methods target
      singleton_class =
        class << target
          self
        end
      prepend_features singleton_class
    end

    NOT_SPECIFIED = Object.new

    def stub method_name_or_hash, returned_value = NOT_SPECIFIED, &definition
      case method_name_or_hash
      when Hash
        hash = method_name_or_hash
        hash.each do|method_name, value|
          stub method_name, value
        end
      when Symbol, String
        self.module_exec method_name_or_hash do|method_name|
          # TODO: should not ignore arguments?
          define_method(method_name) {|*_arguments| returned_value }
        end
      end
      self
    end

  end
end

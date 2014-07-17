module Crispy
  module StubberMixin
    NOT_SPECIFIED = ::Object.new

    def initialize_stubs stubs_map = {}
      stub stubs_map
    end

    def stub method_name_or_hash, returned_value = NOT_SPECIFIED, &definition
      case method_name_or_hash
      when Hash
        hash = method_name_or_hash
        hash.each do|method_name, value|
          stub method_name, value
        end
      when Symbol, String
        self.singleton_class.class_exec method_name_or_hash do|method_name|
          define_method method_name { returned_value }
        end
      end
      self
    end

  end
end

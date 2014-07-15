module Crispy
  module StubberMixin
    NOT_SPECIFIED = ::Object.new

    def stub method_name, returned_value = NOT_SPECIFIED, &definition
      class << self
        define_method method_name { returned_value }
      end
      self
    end

  end
end

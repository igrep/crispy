require 'crispy/spy_base'

module Crispy
  class ObjectSpy < SpyBase

    def initialize delegate
      @delegate = delegate
    end

    def __crispy_execute_method__ method_name, *arguments, &attached_block
      @delegate.__send__ method_name, *arguments, &attached_block
    end

  end
end

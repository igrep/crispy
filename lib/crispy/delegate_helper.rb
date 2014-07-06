module Crispy
  module DelegateHelper

    def initialize delegate
      @delegate = delegate
    end

    def delegate_send method_name, *arguments, &attached_block
      @delegate.__send__ method_name, *arguments, &attached_block
    end

  end
end

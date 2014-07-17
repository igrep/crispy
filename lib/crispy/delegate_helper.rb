module Crispy
  module DelegateHelper

    def initialize_delegate delegate
      @delegate = delegate
    end

    def delegate_send method_name, *arguments, &attached_block
      @delegate.public_send method_name, *arguments, &attached_block
    end

  end
end

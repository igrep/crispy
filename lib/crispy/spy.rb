require 'crispy/spy_base'

module Crispy
  class Spy < SpyBase

    def __crispy_execute_method__ _method_name, *_arguments, &_attached_block
      self
    end

  end
end

require 'crispy/spy_base'

module Crispy
  class Spy < SpyBase
    include StubberMixin

    def execute_method _method_name, *_arguments, &_attached_block
      self
    end

  end
end

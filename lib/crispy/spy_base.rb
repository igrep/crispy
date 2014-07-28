require 'crispy/spied_message'
require 'crispy/stubber_mixin'
require 'crispy/spy_mixin'

module Crispy
  class SpyBase < ::BasicObject
    include StubberMixin
    include SpyMixin

    attr_reader :spied_messages

    def method_missing method_name, *arguments, &attached_block
      @spied_messages ||= []
      @spied_messages << SpiedMessage.new(method_name, *arguments, &attached_block)

      execute_method method_name, *arguments, &attached_block
    end

    def execute_method method_name, *arguments, &attached_block
      raise ::NotImplementedError
    end
    private :execute_method

  end
end

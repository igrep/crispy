require 'crispy/spied_message'

module Crispy
  class SpyBase < ::BasicObject

    attr_reader :spied_messages
    alias __crispy_spied_messages__ spied_messages

    def method_missing method_name, *arguments, &attached_block
      @spied_messages ||= []
      @spied_messages << SpiedMessage.new(method_name, *arguments, &attached_block)

      __crispy_execute_method__ method_name, *arguments, &attached_block
    end

    def __crispy_execute_method__ method_name, *arguments, &attached_block
      raise ::NotImplementedError
    end
    private :__crispy_execute_method__

    def spied? method_name, *arguments, &attached_block
      if arguments.empty? and attached_block.nil?
        @spied_messages.map(&:method_name).include? method_name
      else
        @spied_messages.include? SpiedMessage.new(method_name, *arguments, &attached_block)
      end
    end
    alias __crispy_spied? spied?

    def spied_once? method_name, *arguments, &attached_block
      if arguments.empty? and attached_block.nil?
        @spied_messages.map(&:method_name).one? {|self_method_name| self_method_name == method_name }
      else
        @spied_messages.one? {|self_spied_messages| self_spied_messages == SpiedMessage.new(method_name, *arguments, &attached_block) }
      end
    end
    alias __crispy_spied_once? spied_once?

    def count_spied method_name, *arguments, &attached_block
      if arguments.empty? and attached_block.nil?
        @spied_messages.map(&:method_name).count method_name
      else
        @spied_messages.count SpiedMessage.new(method_name, *arguments, &attached_block)
      end
    end
    alias __crispy_count_spied count_spied

  end
end

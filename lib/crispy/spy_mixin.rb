require 'crispy/spied_message'

module Crispy
  module SpyMixin

    attr_reader :spied_messages

    def spied? method_name, *arguments, &attached_block
      if arguments.empty? and attached_block.nil?
        @spied_messages.map(&:method_name).include? method_name
      else
        @spied_messages.include? SpiedMessage.new(method_name, *arguments, &attached_block)
      end
    end

    def spied_once? method_name, *arguments, &attached_block
      if arguments.empty? and attached_block.nil?
        @spied_messages.map(&:method_name).one? {|self_method_name| self_method_name == method_name }
      else
        @spied_messages.one? {|self_spied_messages| self_spied_messages == SpiedMessage.new(method_name, *arguments, &attached_block) }
      end
    end

    def count_spied method_name, *arguments, &attached_block
      if arguments.empty? and attached_block.nil?
        @spied_messages.map(&:method_name).count method_name
      else
        @spied_messages.count SpiedMessage.new(method_name, *arguments, &attached_block)
      end
    end

  end
end

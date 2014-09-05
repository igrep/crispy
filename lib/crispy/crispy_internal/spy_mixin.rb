require 'crispy/crispy_received_message'

module Crispy
  module CrispyInternal
    module SpyMixin

      attr_reader :received_messages

      def received? method_name, *arguments, &attached_block
        if arguments.empty? and attached_block.nil?
          @received_messages.map(&:method_name).include? method_name
        else
          @received_messages.include? ::Crispy::CrispyReceivedMessage.new(method_name, *arguments, &attached_block)
        end
      end

      def received_once? method_name, *arguments, &attached_block
        if arguments.empty? and attached_block.nil?
          @received_messages.map(&:method_name).one? {|self_method_name| self_method_name == method_name }
        else
          @received_messages.one? do |self_received_message|
            self_received_message == ::Crispy::CrispyReceivedMessage.new(method_name, *arguments, &attached_block)
          end
        end
      end

      def count_received method_name, *arguments, &attached_block
        if arguments.empty? and attached_block.nil?
          @received_messages.map(&:method_name).count method_name
        else
          @received_messages.count ::Crispy::CrispyReceivedMessage.new(method_name, *arguments, &attached_block)
        end
      end

    end
  end
end

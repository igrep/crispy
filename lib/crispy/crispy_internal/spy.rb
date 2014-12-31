require 'crispy/crispy_received_message'
require 'crispy/crispy_internal/spy_base'

module Crispy
  module CrispyInternal
    class Spy < SpyBase

      attr_reader :received_messages

      def initialize target, stubs_map = {}
        @received_messages = []
        super
      end

      def self.method_name_to_retrieve_spy
        :__CRISPY_SPY__
      end

      def target_to_class target
        class << target
          self
        end
      end

      def erase_log
        @received_messages.clear
      end

      def self.of_target target
        (defined? target.__CRISPY_SPY__) && target.__CRISPY_SPY__
      end

      def append_received_message receiver, method_name, *arguments, &attached_block
        @received_messages <<
          ::Crispy::CrispyReceivedMessage.new(method_name, *arguments, &attached_block)
      end
      private :append_received_message

    end
  end
end

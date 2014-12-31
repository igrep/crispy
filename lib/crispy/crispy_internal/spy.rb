require 'crispy/crispy_received_message'
require 'crispy/crispy_internal/spy_base'

module Crispy
  module CrispyInternal
    class Spy < SpyBase

      attr_reader :received_messages

      def initialize target, stubs_map = {}
        @received_messages = []

        singleton_class =
          class << target
            self
          end
        prepend_features singleton_class

        super
      end

      def self.method_name_to_retrieve_spy
        :__CRISPY_SPY__
      end

      def erase_log
        @received_messages.clear
      end

      def append_received_message receiver, method_name, *arguments, &attached_block
        @received_messages <<
          ::Crispy::CrispyReceivedMessage.new(method_name, *arguments, &attached_block)
      end
      private :append_received_message

      def self.new target, stubs_map = {}
        if defined? target.__CRISPY_SPY__
          spy = target.__CRISPY_SPY__
          spy.restart
          spy.erase_log
          spy.reinitialize_stubber stubs_map
          spy
        else
          super
        end
      end

    end
  end
end

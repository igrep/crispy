require 'crispy/crispy_received_message'
require 'crispy/crispy_internal/spy_base'

require 'weakref'

module Crispy
  module CrispyInternal
    class Spy < SpyBase

      @spies_to_reset = []

      attr_reader :received_messages

      def initialize target, except: []
        spy = self
        module_eval do
          define_method(:__CRISPY_SPY__) { spy }
        end

        @received_messages = []
        super

        self.class.remember_to_reset_later self
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

      def self.remember_to_reset_later spy
        @spies_to_reset << ::WeakRef.new(spy)
      end

      def self.reset_all
        # get rid of spies of GCed objects
        @spies_to_reset.select! do|spy|
          if alive = spy.weakref_alive?
            spy.reinitialize
          end
          alive
        end
      end

    end
  end
end

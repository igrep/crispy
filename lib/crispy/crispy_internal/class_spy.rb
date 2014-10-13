require 'crispy/crispy_received_message_with_receiver'
require 'crispy/crispy_internal/spy_mixin'
require 'crispy/crispy_internal/with_stubber'

module Crispy
  module CrispyInternal
    class ClassSpy < ::Module
      include SpyMixin
      include WithStubber

      @registry = {}

      attr_reader :received_messages_with_receiver

      def initialize klass, stubs_map = {}
        spy = self
        super() do
          define_method(:__CRISPY_CLASS_SPY__) { spy }
        end

        @received_messages_with_receiver = []

        initialize_stubber stubs_map
        prepend_stubber klass

        prepend_features klass
        self.class.register spy: spy, of_class: klass
      end

      def received_messages
        @received_messages_with_receiver.map {|m| m.received_message }
      end

      def erase_log
        @received_messages_with_receiver.clear
      end

      def define_wrapper method_name
        define_method method_name do|*arguments, &attached_block|
          __CRISPY_CLASS_SPY__.received_messages_with_receiver <<
            ::Crispy::CrispyReceivedMessageWithReceiver.new(self, method_name, *arguments, &attached_block)

          super(*arguments, &attached_block)
        end
        method_name
      end
      private :define_wrapper

      class Target

        def initialize klass
          @target_class = klass
        end

        def as_class
          @target_class
        end

        # define accessor after prepending to avoid to spy unexpectedly.
        def pass_spy_through spy
          spy.module_eval do
            define_method(:__CRISPY_CLASS_SPY__) { spy }
          end
          ::Crispy::CrispyInternal::ClassSpy.register spy: spy, of_class: @target_class
        end

      end

      def self.new klass, stubs_map = {}
        self.of_class(klass) || super
      end

      def self.register(spy: nil, of_class: nil)
        @registry[of_class] = spy
      end

      def self.of_class(klass)
        @registry[klass]
      end

      def self.erase_all_logs
        @registry.each_value(&:erase_log)
      end

    end
  end
end

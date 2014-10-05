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
          def __CRISPY_APPEND_RECEIVED_MESSAGE__ receiver, method_name, *arguments, &attached_block
            __CRISPY_CLASS_SPY__.received_messages_with_receiver <<
              ::Crispy::CrispyReceivedMessageWithReceiver.new(receiver, method_name, *arguments, &attached_block)
          end
        end

        @received_messages_with_receiver = []

        initialize_stubber stubs_map
        prepend_stubber klass

        prepend_features klass
        ::Crispy::CrispyInternal::ClassSpy.register spy: spy, of_class: klass
      end

      def received_messages
        @received_messages_with_receiver.map {|m| m.received_message }
      end

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

      def self.register(spy: nil, of_class: nil)
        @registry[of_class] = spy
      end

      def self.of_class(klass)
        @registry[klass]
      end

    end
  end
end

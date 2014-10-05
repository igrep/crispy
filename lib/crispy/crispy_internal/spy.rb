require 'crispy/crispy_received_message'
require 'crispy/crispy_internal/spy_mixin'
require 'crispy/crispy_internal/with_stubber'

module Crispy
  module CrispyInternal
    class Spy < ::Module
      include SpyMixin
      include WithStubber

      def initialize target, stubs_map = {}
        super() do
          spy = self
          define_method(:__CRISPY_SPY__) { spy }
          def __CRISPY_APPEND_RECEIVED_MESSAGE__ _receiver, method_name, *arguments, &attached_block
            __CRISPY_SPY__.received_messages <<
              ::Crispy::CrispyReceivedMessage.new(method_name, *arguments, &attached_block)
          end
        end

        @received_messages = []
        singleton_class =
          class << target
            self
          end
        initialize_stubber stubs_map
        prepend_stubber singleton_class

        prepend_features singleton_class
      end

      class Target

        def initialize object, object_singleton_class
          @target_object = object
          @target_object_singleton_class = object_singleton_class
        end

        def as_class
          @target_object_singleton_class
        end

        def pass_spy_through spy
          spy.module_eval { attr_accessor :__CRISPY_SPY__ }
          @target_object.__CRISPY_SPY__ = spy
        end

      end

    end
  end
end

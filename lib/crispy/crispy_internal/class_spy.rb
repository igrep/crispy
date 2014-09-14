module Crispy
  module CrispyInternal
    class ClassSpy < ::Module
      include SpyMixin
      include WithStubber

      def initialize klass, stubs_map = {}
        super()
        @received_messages = []

        initialize_stubber stubs_map
        prepend_stubber klass

        sneak_into Target.new(klass)
      end

      def define_wrapper method_name
        define_method method_name do|*arguments, &attached_block|
          self.class.__CRISPY_CLASS_SPY__.received_messages <<
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
          class << @target_class
            attr_accessor :__CRISPY_CLASS_SPY__
          end

          @target_class.__CRISPY_CLASS_SPY__ = spy
        end

      end

    end
  end
end

module Crispy
  module CrispyInternal
    class ClassSpy < ::Module
      include SpyMixin
      include WithStubber

      @registry = {}

      def initialize klass, stubs_map = {}
        super()
        @received_messages = []

        initialize_stubber stubs_map
        prepend_stubber klass

        sneak_into Target.new(klass)
      end

      def define_wrapper method_name
        #return method_name if method_name == :initialize
        return method_name if method_name == :method_missing
        p method_name
        define_method method_name do|*arguments, &attached_block|
          #::Kernel.print "e" # <= with this statement, prepend-ing :method_missing doesn't cause the segfault.
          ::Crispy::CrispyInternal::ClassSpy.of_class(::Kernel.p self.class).received_messages <<
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

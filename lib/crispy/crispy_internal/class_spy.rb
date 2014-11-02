require 'crispy/crispy_received_message_with_receiver'
require 'crispy/crispy_internal/spy_mixin'
require 'crispy/crispy_internal/with_stubber'

module Crispy
  module CrispyInternal
    class ClassSpy < ::Module
      include SpyMixin
      #include WithStubber

      @registry = {}

      def initialize klass#, stubs_map = {}
        spy = self
        super() do
          define_method(:__CRISPY_CLASS_SPY__) { spy }
        end

        @received_messages_with_receiver = []
        initialize_spy

        #initialize_stubber stubs_map
        #prepend_stubber klass

        prepend_features klass
        self.class.register spy: spy, of_class: klass
      end

      def received_messages
        @received_messages_with_receiver.map {|m| m.received_message }
      end

      def received_messages_with_receiver
        # stop spying in advance to prevent from unexpectedly spying receiver's methods in test code.
        self.stop
        @received_messages_with_receiver
      end

      COMMON_RECEIVED_MESSAGE_METHODS_DEFINITION.each do|method_name, core_definition|
        method_name_with_receiver = method_name.sub(/\??\z/) do|question_mark|
          "_with_receiver#{question_mark}"
        end

        binding.eval(<<-END, __FILE__, (__LINE__ + 1))
          def #{method_name_with_receiver} receiver, received_method_name, *received_arguments, &received_block
            if received_arguments.empty? and received_block.nil?
              recevier_and_received_method_name = [receiver, received_method_name]
              received_messages_with_receiver.map do|received_message_with_receiver|
                [received_message_with_receiver.receiver, received_message_with_receiver.method_name]
              end.#{sprintf(core_definition, 'recevier_and_received_method_name')}
            else
              received_message_with_receiver = ::Crispy::CrispyReceivedMessageWithReceiver.new(
                receiver, received_method_name, *received_arguments, &received_block
              )
              received_messages_with_receiver.#{sprintf(core_definition, 'received_message_with_receiver')}
            end
          end
        END
      end

      def erase_log
        @received_messages_with_receiver.clear
      end

      def append_received_message_with_receiver receiver, method_name, *arguments, &attached_block
        if @spying
          @received_messages_with_receiver <<
            ::Crispy::CrispyReceivedMessageWithReceiver.new(receiver, method_name, *arguments, &attached_block)
        end
      end

      def define_wrapper method_name
        define_method method_name do|*arguments, &attached_block|
          __CRISPY_CLASS_SPY__.append_received_message_with_receiver self, method_name, *arguments, &attached_block

          super(*arguments, &attached_block)
        end
        method_name
      end
      private :define_wrapper

      def self.new klass#, stubs_map = {}
        spy = self.of_class(klass)
        if spy
          spy.restart
          spy.erase_log
          spy
        else
          super
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

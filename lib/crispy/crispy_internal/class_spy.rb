require 'crispy/crispy_received_message_with_receiver'
require 'crispy/crispy_internal/spy_base'

module Crispy
  module CrispyInternal
    class ClassSpy < SpyBase

      @registry = {}

      def initialize klass, except: []
        @received_messages_with_receiver = []

        super

        self.class.register spy: self, of_class: klass
      end

      def self.of_target klass
        @registry[klass]
      end

      def target_to_class target_class
        target_class
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
            assert_symbol! received_method_name
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

      def append_received_message receiver, method_name, *arguments, &attached_block
        @received_messages_with_receiver <<
          ::Crispy::CrispyReceivedMessageWithReceiver.new(receiver, method_name, *arguments, &attached_block)
      end
      private :append_received_message

      def self.register(spy: nil, of_class: nil)
        @registry[of_class] = spy
      end

      def self.reset_all
        @registry.each_value {|spy| spy.reinitialize }
      end

    end
  end
end

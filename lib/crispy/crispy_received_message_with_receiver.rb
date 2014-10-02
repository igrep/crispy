require 'crispy/crispy_received_message'

module Crispy
  class CrispyReceivedMessageWithReceiver
    attr_reader :receiver, :received_message

    CrispyReceivedMessage::DELEGATABLE_METHODS.each do|method_name|
      binding.eval(<<-END, __FILE__, (__LINE__ + 1))
        def #{method_name}
          @received_message.#{method_name}
        end
      END
    end

    def initialize receiver, method_name, *arguments, &attached_block
      @received_message = CrispyReceivedMessage.new(method_name, *arguments, &attached_block)
      @receiver = receiver
    end

    def == other
      @receiver == other.receiver && @received_message == other.received_message
    end

  end
end

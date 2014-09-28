module Crispy
  class CrispyReceivedMessageWithReceiver < CrispyReceivedMessage
    attr_reader :receiver

    def initialize receiver, method_name, *arguments, &attached_block
      @receiver = receiver
      super(receiver, method_name, *arguments, &attached_block)
    end

    def == other
      @receiver == other.receiver && super
    end

  end
end

require 'pp'

require 'crispy/crispy_received_message'

module Crispy
  class CrispyReceivedMessageWithReceiver
    attr_reader :receiver, :received_message

    class << self
      alias [] new
    end

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

    CLASS_NAME = self.name

    def to_s
      "#<#{CLASS_NAME}[#{@receiver.inspect}, #{(@received_message.method_name).inspect}, *#{@received_message.arguments.inspect}]>"
    end

    alias inspect to_s

    PP_HEADER = "#<#{CLASS_NAME}["

    def pretty_print pp
      pp.group 2, PP_HEADER do
        pp.pp @receiver
        pp.text ','.freeze
        pp.breakable

        pp.pp @received_message.method_name
        pp.text ','.freeze
        pp.breakable

        pp.text '*'.freeze
        pp.pp @received_message.arguments
        pp.text ']>'.freeze
      end
    end

    PP_CYCLE = "#{PP_HEADER}...]>"

    def pretty_print_cycle pp
      pp.text PP_CYCLE
    end

  end
end

module Crispy
  class CrispyReceivedMessage

    DELEGATABLE_METHODS = [:method_name, :arguments, :attached_block]

    attr_reader(*DELEGATABLE_METHODS)

    class << self
      alias [] new
    end

    def initialize method_name, *arguments, &attached_block
      @method_name = method_name
      @arguments = arguments
      @attached_block = attached_block
    end

    def == other
      @method_name == other.method_name &&
      @arguments == other.arguments # &&
      # @attached_block == other.attached_block
    end

    CLASS_NAME = self.name

    def to_s
      "#<#{CLASS_NAME}[#{@method_name.inspect}, *#{@arguments.inspect}]>"
    end

    alias inspect to_s

    PP_HEADER = "#<#{CLASS_NAME}["

    def pretty_print pp
      pp.group 2, PP_HEADER do
        pp.pp @method_name
        pp.text ','.freeze
        pp.breakable
        pp.text '*'.freeze
        pp.pp @arguments
        pp.text ']>'.freeze
      end
    end

    PP_CYCLE = "#{PP_HEADER}...]>"

    def pretty_print_cycle pp
      pp.text PP_CYCLE
    end

  end
end

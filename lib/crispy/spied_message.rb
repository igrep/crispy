module Crispy
  class SpiedMessage

    attr_reader :method_name, :arguments, :attached_block

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
      @arguments == other.arguments &&
      @attached_block == other.attached_block
    end

  end
end

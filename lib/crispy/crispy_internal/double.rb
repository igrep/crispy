module Crispy
  module CrispyInternal
    class Double

      def initialize name_or_stubs_map = nil, stubs_map = {}
        if name_or_stubs_map.is_a? ::Hash
          @name = ''.freeze
          @spy = ::Crispy.spy_into(self, name_or_stubs_map)
        else
          @name = name_or_stubs_map
          @spy = ::Crispy.spy_into(self, stubs_map)
        end
      end

      def stub *arguments, &definition
        @spy.stub(*arguments, &definition)
      end

    end
  end
end

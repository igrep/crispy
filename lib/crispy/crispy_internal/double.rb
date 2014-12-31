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

      def received_messages
        @spy.received_messages
      end

      SpyBase::COMMON_RECEIVED_MESSAGE_METHODS_DEFINITION.each_key do|method_name|
        binding.eval(<<-END, __FILE__, (__LINE__ + 1))
          def #{method_name} received_method_name, *received_arguments, &received_block
            @spy.#{method_name} received_method_name, *received_arguments, &received_block
          end
        END
      end

    end
  end
end

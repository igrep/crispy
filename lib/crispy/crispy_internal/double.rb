require 'crispy/crispy_internal/with_stubber'

module Crispy
  module CrispyInternal
    class Double
      include WithStubber

      def initialize name_or_stubs_map = nil, stubs_map = {}
        if name_or_stubs_map.is_a? ::Hash
          @name = ''.freeze
          initialize_stubber(name_or_stubs_map)
        else
          @name = name_or_stubs_map
          initialize_stubber(stubs_map)
        end
        singleton_class =
          class << self
            self
          end
        prepend_stubber singleton_class

        ::Crispy.spy_into self
      end

    end
  end
end

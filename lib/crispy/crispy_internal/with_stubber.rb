require 'crispy/crispy_internal/stubber'

module Crispy
  module CrispyInternal
    module WithStubber

      def initialize_stubber stubs_map = {}
        @__CRISPY_STUBBER__ = Stubber.new(stubs_map)
      end
      private :initialize_stubber

      def prepend_stubber klass
        @__CRISPY_STUBBER__.prepend_features klass
      end
      private :prepend_stubber

      def reinitialize_stubber stubs_map = {}
        @__CRISPY_STUBBER__.reinitialize stubs_map
      end

      def stub *arguments, &definition
        @__CRISPY_STUBBER__.stub(*arguments, &definition)
        self
      end

    end
  end
end

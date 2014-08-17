require 'crispy/stubber'

module Crispy
  module WithStubber

    private def initialize_stubber stubs_map = {}
      @__CRISPY_STUBBER__ = Stubber.new(stubs_map)
    end

    private def prepend_stubber klass
      @__CRISPY_STUBBER__.prepend_features klass
    end

    def stub *arguments, &definition
      @__CRISPY_STUBBER__.stub(*arguments, &definition)
      self
    end

  end
end

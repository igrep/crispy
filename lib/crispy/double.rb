require 'crispy/stubber'

module Crispy
  class Double

    def initialize name_or_stubs_map = nil, stubs_map = {}
      if name_or_stubs_map.is_a? Hash
        @name = ''.freeze
        @__CRISPY_STUBBER__ = Stubber.new(name_or_stubs_map)
      else
        @name = name_or_stubs_map
        @__CRISPY_STUBBER__ = Stubber.new(stubs_map)
      end
      @__CRISPY_STUBBER__.prepend_stubbed_methods self
    end

    def stub stubs_map
      @__CRISPY_STUBBER__.stub stubs_map
    end

  end
end

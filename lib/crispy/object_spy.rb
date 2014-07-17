require 'crispy/spy_base'
require 'crispy/delegate_helper'

module Crispy
  class ObjectSpy < SpyBase
    include DelegateHelper
    include StubberMixin

    def initialize delegate, stubs_map = {}
      initialize_delegate delegate
      initialize_stubs stubs_map
    end

    alias execute_method delegate_send!
  end
end

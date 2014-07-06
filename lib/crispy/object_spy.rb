require 'crispy/spy_base'
require 'crispy/delegate_helper'

module Crispy
  class ObjectSpy < SpyBase
    include DelegateHelper
    alias execute_method delegate_send
  end
end

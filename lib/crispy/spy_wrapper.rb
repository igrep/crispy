require 'crispy/received_message'
require 'crispy/spy_mixin'

module Crispy
  class SpyWrapper < Module
    include SpyMixin

    def initialize target, stubs_map = {}
      super()
      @received_messages = []
      singleton_class =
        class << target
          self
        end
      target.instance_exec self do|spy|
        @__CRISPY_SPY__ = spy
      end
      @__CRISPY_STUBBER__ = Stubber.new(stubs_map)
      @__CRISPY_STUBBER__.prepend_features singleton_class
      prepend_features singleton_class
    end

    def prepend_features klass
      super
      klass.public_instance_methods.each do|method_name|
        self.module_eval { public define_wrapper(method_name) }
      end
      klass.protected_instance_methods.each do|method_name|
        self.module_eval { protected define_wrapper(method_name) }
      end
      klass.private_instance_methods.each do|method_name|
        self.module_eval { private define_wrapper(method_name) }
      end
    end

    NOT_SPECIFIED = Object.new

    def stub *arguments, &definition
      @__CRISPY_STUBBER__.stub(*arguments, &definition)
      self
    end

    private def define_wrapper method_name
      define_method method_name do|*arguments, &attached_block|
        @__CRISPY_SPY__.received_messages << ReceivedMessage.new(method_name, *arguments, &attached_block)
        super(*arguments, &attached_block)
      end
      method_name
    end

  end
end

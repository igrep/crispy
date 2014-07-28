require 'crispy/spied_message'
require 'crispy/spy_mixin'

module Crispy
  class SpyWrapper < Module
    include SpyMixin

    def initialize target
      super()
      @spied_messages = []
      singleton_class =
        class << target
          self
        end
      target.instance_exec self do|spy|
        @__CRISPY_SPY__ = spy
      end
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

    private
      def define_wrapper method_name
        define_method method_name do|*arguments, &attached_block|
          @__CRISPY_SPY__.spied_messages << SpiedMessage.new(method_name, *arguments, &attached_block)
          super(*arguments, &attached_block)
        end
        method_name
      end

  end
end

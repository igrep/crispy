require 'crispy/crispy_received_message'

module Crispy
  module CrispyInternal
    module SpyMixin

      BLACK_LISTED_METHODS = [
        :__CRISPY_CLASS_SPY__,
        :__CRISPY_SPY__,
      ]

      def received_messages
        raise NotImplementedError
      end

      def erase_log
        raise NotImplementedError
      end

      def stop
        @spying = false
      end

      def restart
        @spying = true
      end

      COMMON_RECEIVED_MESSAGE_METHODS_DEFINITION = {
        'received?'      => 'include? %s',
        'received_once?' => 'one? {|self_thing| self_thing == %s }',
        'count_received' => 'count %s',
      }

      COMMON_RECEIVED_MESSAGE_METHODS_DEFINITION.each do|method_name, core_definition|
        binding.eval(<<-END, __FILE__, (__LINE__ + 1))
          def #{method_name} received_method_name, *received_arguments, &received_block
            if received_arguments.empty? and received_block.nil?
              received_messages.map(&:method_name).#{sprintf(core_definition, 'received_method_name')}
            else
              received_message = ::Crispy::CrispyReceivedMessage.new(
                received_method_name, *received_arguments, &received_block
              )
              received_messages.#{sprintf(core_definition, 'received_message')}
            end
          end
        END
      end

      def prepend_features klass
        super

        without_black_listed_methods(klass.public_instance_methods).each do|method_name|
          self.module_eval { define_wrapper(method_name) }
        end
        klass.protected_instance_methods.each do|method_name|
          self.module_eval { protected define_wrapper(method_name) }
        end
        klass.private_instance_methods.each do|method_name|
          self.module_eval { private define_wrapper(method_name) }
        end
      end
      private :prepend_features

      def without_black_listed_methods method_names
        method_names.reject {|method_name| BLACK_LISTED_METHODS.include? method_name }
      end
      private :without_black_listed_methods

      def initialize_spy
        @spying = true
      end
      private :initialize_spy

    end
  end
end

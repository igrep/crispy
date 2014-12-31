require 'crispy/crispy_received_message'

module Crispy
  module CrispyInternal
    class SpyBase < ::Module

      public :remove_method

      BLACK_LISTED_METHODS = [
        :__CRISPY_SPY__,
      ]

      def initialize target, stubs_map = {}
        prepend_features target_to_class(target)

        @stubbed_methods = []
        stub stubs_map

        @spying = true
      end

      def self.new target, stubs_map = {}
        spy = self.of_target(target)
        if spy
          spy.restart
          spy.erase_log
          spy.reinitialize_stubber stubs_map
          spy
        else
          super
        end
      end

      def self.of_target target
        raise NotImplementedError
      end

      def target_to_class target
        raise NotImplementedError
      end

      def received_messages
        raise NotImplementedError
      end

      def erase_log
        raise NotImplementedError
      end

      def append_received_message receiver, method_name, *arguments, &attached_block
        raise NotImplementedError
      end

      def stop
        @spying = false
      end

      def restart
        @spying = true
      end

      def define_wrapper method_name
        spy = self
        define_method method_name do|*arguments, &attached_block|
          spy.append_received_message_when_spying(self, method_name, *arguments, &attached_block)

          super(*arguments, &attached_block)
        end
        method_name
      end
      private :define_wrapper

      def append_received_message_when_spying receiver, method_name, *arguments, &attached_block
        if @spying
          append_received_message receiver, method_name, *arguments, &attached_block
        end
      end

      COMMON_RECEIVED_MESSAGE_METHODS_DEFINITION = {
        'received?'      => 'include? %s',
        'received_once?' => 'one? {|self_thing| self_thing == %s }',
        'count_received' => 'count %s',
      }

      COMMON_RECEIVED_MESSAGE_METHODS_DEFINITION.each do|method_name, core_definition|
        binding.eval(<<-END, __FILE__, (__LINE__ + 1))
          def #{method_name} received_method_name, *received_arguments, &received_block
            assert_symbol! received_method_name
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

      def stub method_name_or_hash, returned_value = nil, &definition
        case method_name_or_hash
        when Hash
          hash = method_name_or_hash
          hash.each do|method_name, value|
            stub method_name, value
          end
        when ::Symbol, ::String
          @stubbed_methods << method_name_or_hash

          self.module_exec method_name_or_hash do|method_name|
            spy = self

            # remove methods already defined (maybe by define_wrapper) to avoid warning.
            remove_method method_name if public_method_defined? method_name

            # TODO: should not ignore arguments?
            define_method(method_name) do|*arguments, &block|
              spy.append_received_message_when_spying self, method_name, *arguments, &block
              returned_value
            end
          end
        end
        self
      end

      def reinitialize_stubber stubs_map = {}
        remove_method(*@stubbed_methods)
        @stubbed_methods.clear
        stub stubs_map
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

      def assert_symbol! maybe_symbol
        unless maybe_symbol.respond_to?(:to_sym) && maybe_symbol.to_sym.instance_of?(::Symbol)
          raise TypeError, "TypeError: no implicit conversion from #{maybe_symbol.inspect} to symbol"
        end
      end

    end
  end
end

require 'crispy/crispy_received_message'

module Crispy
  module CrispyInternal
    class SpyBase < ::Module

      public :remove_method

      BLACK_LISTED_METHODS = [
        :__CRISPY_SPY__,
      ]

      def initialize target, except: []
        @exceptions = Array(except).map(&:to_sym)

        prepend_features target_to_class(target)

        @stubbed_methods = []

        @spying = true
      end

      def self.new target, except: []
        spy = self.of_target(target)
        if spy
          spy.update_exceptions(target, except)
          spy.reinitialize
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

      def reinitialize
        restart
        erase_log
        reinitialize_stubber
        self
      end

      def update_exceptions target, exceptions
        return if exceptions.empty?

        given_exceptions = Array(exceptions).map(&:to_sym)

        new_exceptions = given_exceptions - @exceptions
        remove_method(*new_exceptions)

        old_exceptions = @exceptions - given_exceptions
        redefine_wrappers target_to_class(target), old_exceptions

        @exceptions.replace given_exceptions
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

      def reinitialize_stubber
        remove_method(*@stubbed_methods)
        @stubbed_methods.each {|stubbed_method| define_wrapper stubbed_method }
        @stubbed_methods.clear
      end

      %w[only except].each do|inclusion|
        not_sign = inclusion == 'except'.freeze ? '!'.freeze : ''.freeze
        %w[public protected private].each do|visibility|
          binding.eval(<<-END, __FILE__, (__LINE__ + 1))
            def define_#{visibility}_wrappers_#{inclusion} klass, targets
              klass.#{visibility}_instance_methods.each do|method_name|
                #{visibility} define_wrapper(method_name) if method_name != :__CRISPY_SPY__ && #{not_sign}targets.include?(method_name)
              end
            end
          END
        end
      end

      def prepend_features klass
        super

        self.module_eval do
          define_public_wrappers_except(klass, @exceptions)
          define_protected_wrappers_except(klass, @exceptions)
          define_private_wrappers_except(klass, @exceptions)
        end
      end
      private :prepend_features

      def redefine_wrappers klass, method_names
        self.module_eval do
          define_public_wrappers_only(klass, method_names)
          define_protected_wrappers_only(klass, method_names)
          define_private_wrappers_only(klass, method_names)
        end
      end

      def assert_symbol! maybe_symbol
        unless maybe_symbol.respond_to?(:to_sym) && maybe_symbol.to_sym.instance_of?(::Symbol)
          raise TypeError, "TypeError: no implicit conversion from #{maybe_symbol.inspect} to symbol"
        end
      end

    end
  end
end

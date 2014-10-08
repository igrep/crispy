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

      def received? method_name, *arguments, &attached_block
        if arguments.empty? and attached_block.nil?
          received_messages.map(&:method_name).include? method_name
        else
          received_messages.include? ::Crispy::CrispyReceivedMessage.new(method_name, *arguments, &attached_block)
        end
      end

      def received_once? method_name, *arguments, &attached_block
        if arguments.empty? and attached_block.nil?
          received_messages.map(&:method_name).one? {|self_method_name| self_method_name == method_name }
        else
          received_messages.one? do |self_received_message|
            self_received_message == ::Crispy::CrispyReceivedMessage.new(method_name, *arguments, &attached_block)
          end
        end
      end

      def count_received method_name, *arguments, &attached_block
        if arguments.empty? and attached_block.nil?
          received_messages.map(&:method_name).count method_name
        else
          received_messages.count ::Crispy::CrispyReceivedMessage.new(method_name, *arguments, &attached_block)
        end
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

      def sneak_into target
        prepend_features target.as_class
        target.pass_spy_through self
      end
      private :sneak_into

      def without_black_listed_methods method_names
        method_names.reject {|method_name| BLACK_LISTED_METHODS.include? method_name }
      end
      private :without_black_listed_methods

    end
  end
end

require 'crispy'

module RSpec
  module Crispy
    module CrispyFeatures

    include ::Crispy

      def expect_any_instance_of klass
        CrispyExpectAnyInstanceOf.new klass
      end

      def have_received method_name, *arguments
        CrispyHaveReceived.new method_name, *arguments
      end

      class CrispyExpectAnyInstanceOf

        def initialize klass
          @klass = klass
        end

        def get_spy_of_instances
          ::Crispy.spy_of_instances(@klass)
        end

        def inspect
          "<Some Instances of #@klass>"
        end

      end

      class CrispyHaveReceived

        def initialize method_name, *arguments
          @method_name = method_name
          @arguments = arguments
        end

        def name
          'have_received'.freeze
        end

        def matches?(subject)
          @subject = subject
          @spy_of_subject = spy_of_subject subject
          matched_spy?(@spy_of_subject)
        end

        def matched_spy? spy
          spy.received? @method_name, *@arguments
        end

        def once
          times 1
        end

        def times n
          NTimes.new n, @method_name, *@arguments
        end

        def failure_message
          @spy_of_subject.stop
          result = "Expected #{@subject.inspect} to have received :#@method_name method"
          result << " with #@arguments" unless @arguments.empty?
          result << ".\n"
          result << actually_received_messages_for_failure_message
          result
        end

        def failure_message_when_negated
          @spy_of_subject.stop
          result = "Expected #{@subject.inspect} NOT to have received :#@method_name method"
          result << " with #@arguments" unless @arguments.empty?
          result << ". But actually received.\n".freeze
          result
        end

        def actually_received_messages_for_failure_message
          if @spy_of_subject.received_messages.empty?
            "Actually, it has received no messages.\n".freeze
          else
            result = "Actually, it has received these messages:\n"
            @spy_of_subject.received_messages.each do|received_message|
              arguments_for_message = received_message.arguments.map(&:inspect).join(', '.freeze)
              # TODO: which instance actually received the message for ClassSpy
              result << "  it.#{received_message.method_name}(#{arguments_for_message})\n"
            end
            result
          end
        end

        def spy_of_subject subject
          # Don't use instance_of? method. it records received_messages.
          if CrispyExpectAnyInstanceOf === subject
            subject.get_spy_of_instances
          else
            ::Crispy.spy(subject)
          end
        end

        class NTimes < self

          def initialize n, method_name, *arguments
            super(method_name, *arguments)
            @n = n
          end

          def matched_spy? spy
            @actual_count = spy.count_received(@method_name, *@arguments)
            @n == @actual_count
          end

          def failure_message
            @spy_of_subject.stop
            result = "Expected #{@subject.inspect} to have received :#@method_name method"
            result << " with #@arguments" unless @arguments.empty?
            result << " some particular times.\n"
            result << "  Expected: #@n times.\n"
            result << "    Actual: #@actual_count times.\n"
            result << actually_received_messages_for_failure_message
            result
          end

          def failure_message_when_negated
            @spy_of_subject.stop
            result = "Expected #{@subject.inspect} to have received :#@method_name method"
            result << " with #@arguments" unless @arguments.empty?
            result << " NOT #@n times.\n"
            result << actually_received_messages_for_failure_message
            result
          end

        end

      end

    end

  end
end

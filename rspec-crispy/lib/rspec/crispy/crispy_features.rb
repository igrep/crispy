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

      def have_received_once method_name, *arguments
        CrispyHaveReceived::Once.new method_name, *arguments
      end

      class CrispyExpectAnyInstanceOf

        def initialize klass
          @klass = klass
        end

        def get_spy_of_instances
          raise CrispyError "#{klass} does not have its instances spied!" unless ::Crispy.spied_instances? klass
          ::Crispy.spy_of_instances(@klass)
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
          matched_spy?(spy_of_subject subject)
        end

        def matched_spy? spy
          spy.received? @method_name, *@arguments
        end

        def once
          Once.new @method_name, *@arguments
        end

        def times n
          if n == 1
            Once.new @method_name, *@arguments
          else
            NTimes.new n, @method_name, *@arguments
          end
        end

        def failure_message
        end

        def failure_message_when_negated
        end

        def spy_of_subject subject
          if ::Crispy.spied? subject
            ::Crispy.spy(subject)
          elsif subject.instance_of? ExpectAnyInstanceOf
            subject.get_spy_of_instances
          else
            raise CrispyError "#{subject.inspect} is not spied!"
          end
        end

        class Once < self
          def matched_spy? spy
            spy.received_once? @method_name, *@arguments
          end
        end

        class NTimes < self

          def initialize n, method_name, *arguments
            super(method_name, *arguments)
            @n = n
          end

          def matched_spy? spy
            @n == spy.count_received(@method_name, *@arguments)
          end

        end

      end

    end

    class CrispyError < ::Exception
    end

  end
end

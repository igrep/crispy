require_relative 'test_helper'

$VERBOSE = true # enable warnings

require 'crispy'
require 'minitest/autorun'

class TestCrispy < MiniTest::Test
  include ::Crispy

  module CommonSpyTests

    def test_spy_is_also_returned_by_spy_into_method
      assert_same @subject, @returned_spy
    end

    def test_spy_raises_error_given_non_symbol_as_method_name
      assert_raises(::TypeError){ @subject.received?(nil) }
      assert_raises(::TypeError){ @subject.received_once?(nil) }
      assert_raises(::TypeError){ @subject.count_received(nil) }
    end

  end

  # Inherit BasicObject because it has fewer meta-programming methods than Object
  class ObjectClass < BasicObject

    CONSTANT_TO_STUB = ::Crispy.double('value_before_stubbed')

    def hoge a, b, c
      private_foo a
      [a, b, c]
    end
    def foo
      123
    end
    def bar
      []
    end
    def baz
    end
    def method_to_stub1
      'method to stub 1 (before stubbed)'
    end
    def method_to_stub2
      'method to stub 2 (before stubbed)'
    end
    def method_to_stub3
      'method to stub 3 (before stubbed)'
    end

    def private_foo _
      :private_foo
    end
    private :private_foo

    def self.hoge a, b, c
      private_foo a
      [a, b, c]
    end
    def self.foo
      123
    end

    def self.stubbed_method1
      'before stubbed 1'
    end
    def self.stubbed_method2
      'before stubbed 2'
    end
    def self.stubbed_method3
      'before stubbed 3'
    end

    def self.private_foo a
      :private_foo
    end
    private_class_method :private_foo

  end

  class TestCrispySpied < TestCrispy

    def test_spied_object_is_spied
      spied_object = Object.new
      spy_into spied_object
      assert spied?(spied_object)
    end

    def test_non_spied_object_is_not_spied
      assert not(spied?(Object.new))
    end

  end

  class TestCrispySpiedInstances < TestCrispy

    def test_spied_instances_class_is_spied_instances
      klass = Class.new
      spy_into_instances klass
      assert spied_instances?(klass)
    end

    def test_non_spied_instances_class_is_not_spied_instances
      assert not(spied_instances?(Class.new))
    end

  end

  class TestCrispyStubConst < TestCrispy

    def setup
      @saved_value = ::TestCrispy::ObjectClass::CONSTANT_TO_STUB
      @stubbbed_value = double('value_after_stubbed')
      stub_const '::TestCrispy::ObjectClass::CONSTANT_TO_STUB', @stubbbed_value
    end

    def test_stubbed_const_value_changes_into_2nd_argument_value
      assert_same @stubbbed_value, ::TestCrispy::ObjectClass::CONSTANT_TO_STUB
    end

    def test_stubbed_const_value_changes_back_after_resetting
      CrispyWorld.reset
      assert_same @saved_value, ::TestCrispy::ObjectClass::CONSTANT_TO_STUB
    end

  end

  class TestCrispySpyInto < TestCrispy
    include CommonSpyTests

    def setup
      @object = ObjectClass.new

      @returned_spy = spy_into(@object)
      @returned_spy.stub(method_to_stub1: :stubbed1, method_to_stub2: :stubbed2)

      @object.hoge 1, 2, 3
      @object.foo
      @object.hoge 3, 4, 5

      @subject = spy(@object)
    end

    def test_spy_logs_messages_sent_to_an_object
      assert_equal(
        [
          CrispyReceivedMessage[:hoge, 1, 2, 3],
          CrispyReceivedMessage[:private_foo, 1],
          CrispyReceivedMessage[:foo],
          CrispyReceivedMessage[:hoge, 3, 4, 5],
          CrispyReceivedMessage[:private_foo, 3],
        ],
        @subject.received_messages
      )
    end

    def test_spy_has_received_messages_sent_to_an_object
      assert @subject.received?(:hoge)
      assert @subject.received?(:foo)
      assert not(@subject.received?(:bar))
      assert @subject.received?(:private_foo)
    end

    def test_spy_has_received_messages_with_arguments_sent_to_an_object
      assert @subject.received?(:hoge, 1, 2, 3)
      assert @subject.received?(:hoge, 3, 4, 5)
      assert @subject.received?(:private_foo, 1)
      assert @subject.received?(:private_foo, 3)
      assert not(@subject.received?(:hoge, 0, 0, 0))
      assert not(@subject.received?(:private_foo, 0, 0, 0))
      assert not(@subject.received?(:foo, 1))
      assert not(@subject.received?(:bar, nil))
    end

    def test_spy_has_received_messages_once_sent_to_an_object
      assert not(@subject.received_once?(:hoge))
      assert not(@subject.received_once?(:private_foo))
      assert @subject.received_once?(:hoge, 3, 4, 5)
      assert @subject.received_once?(:private_foo, 3)
      assert not(@subject.received_once?(:private_foo, 3, 4))
      assert @subject.received_once?(:foo)
      assert not(@subject.received_once?(:bar))
    end

    def test_spy_counts_received_messages_sent_to_an_object
      assert_equal(1, @subject.count_received(:hoge, 1, 2, 3))
      assert_equal(1, @subject.count_received(:hoge, 3, 4, 5))
      assert_equal(0, @subject.count_received(:hoge, 0, 0, 0))
      assert_equal(2, @subject.count_received(:hoge))

      assert_equal(1, @subject.count_received(:private_foo, 1))
      assert_equal(1, @subject.count_received(:private_foo, 3))
      assert_equal(0, @subject.count_received(:private_foo, 0))
      assert_equal(2, @subject.count_received(:private_foo))

      assert_equal(1, @subject.count_received(:foo))
      assert_equal(0, @subject.count_received(:bar))
    end

    def test_spy_changes_stubbed_method
      assert_equal(:stubbed1, @object.method_to_stub1)
      assert_equal(:stubbed2, @object.method_to_stub2)
    end

    def test_spy_raises_an_error_given_non_spied_object
      assert_raises(::Crispy::CrispyError){ spy(ObjectClass.new) }
    end

  end

  class TestCrispySpyIntoClass < TestCrispy

    def setup
      spy_into(ObjectClass).stub(stubbed_method1: 1, stubbed_method2: 2)

      ObjectClass.hoge 1, 2, 3
      ObjectClass.foo
      ObjectClass.hoge 3, 4, 5

      @subject = spy(ObjectClass)
    end

    def test_spy_logs_received_messages_not_twice_by_spy_into_twice
      setup

      assert_equal(
        [
          CrispyReceivedMessage[:hoge, 1, 2, 3],
          CrispyReceivedMessage[:private_foo, 1],
          CrispyReceivedMessage[:foo],
          CrispyReceivedMessage[:hoge, 3, 4, 5],
          CrispyReceivedMessage[:private_foo, 3],
        ],
        @subject.received_messages
      )
    end

    def test_spy_overrides_stubbed_methods
      spy_into(ObjectClass).stub(stubbed_method2: 'xx', stubbed_method3: 'xxx')

      assert_equal 'before stubbed 1', ObjectClass.stubbed_method1
      assert_equal 'xx'              , ObjectClass.stubbed_method2
      assert_equal 'xxx'             , ObjectClass.stubbed_method3
    end

    def test_spy_resets_stubbed_methods_after_resetting
      CrispyWorld.reset
      assert_equal 'before stubbed 1', ObjectClass.stubbed_method1
      assert_equal 'before stubbed 2', ObjectClass.stubbed_method2
    end

    def test_spy_forgets_received_messages_after_resetting
      CrispyWorld.reset
      assert_empty @subject.received_messages
    end

    def test_spy_still_logs_methods_stubbed_once_after_resetting
      CrispyWorld.reset

      ObjectClass.stubbed_method1
      assert_equal 1, spy(ObjectClass).count_received(:stubbed_method1)
    end

    def test_spy_of_instances_raises_an_error_given_non_spied_instances_object
      assert_raises(::Crispy::CrispyError){ spy_of_instances(Class.new) }
    end

  end

  class TestCrispySpyIntoInstances < TestCrispy

    def object_class
      raise NotImplementedError
    end

    def setup
      @returned_spy = spy_into_instances(object_class)
      @returned_spy.stub(method_to_stub1: :stubbed_instance_method1, method_to_stub2: :stubbed_instance_method2)

      @subject = spy_of_instances(object_class)
      @object_instances = Array.new(3){ object_class.new }

      @object_instances[0].hoge 3, 4, 5
      @object_instances[1].hoge 1, 2, 3
      @object_instances[0].foo
      @object_instances[2].hoge 3, 4, 5
      @object_instances[1].bar
      @object_instances[2].hoge 7, 8, 9
      @object_instances[1].bar
    end

    def teardown
      CrispyWorld.reset
    end

    module CommonClassSpyTests

      def test_spy_changes_stubbed_method
        @object_instances.each do|object|
          assert_equal(:stubbed_instance_method1, object.method_to_stub1)
          assert_equal(:stubbed_instance_method2, object.method_to_stub2)
        end
      end

      def test_spy_overrides_stubbed_methods
        spy_into_instances(object_class).stub(method_to_stub2: 'xx', method_to_stub3: 'xxx')

        @object_instances.each do|object|
          assert_equal 'method to stub 1 (before stubbed)', object.method_to_stub1
          assert_equal 'xx'                               , object.method_to_stub2
          assert_equal 'xxx'                              , object.method_to_stub3
        end
      end

      def test_spy_resets_stubbed_methods_after_resetting
        ::Crispy::CrispyWorld.reset

        @object_instances.each do|object|
          assert_equal 'method to stub 1 (before stubbed)', object.method_to_stub1
          assert_equal 'method to stub 2 (before stubbed)', object.method_to_stub2
          assert_equal 'method to stub 3 (before stubbed)', object.method_to_stub3
        end
      end

      def test_spy_forgets_received_messages_after_resetting
        ::Crispy::CrispyWorld.reset
        assert_empty @subject.received_messages
        assert_empty @subject.received_messages_with_receiver
      end

    end

    class TestReceivedMessage < self
      include CommonSpyTests
      include CommonClassSpyTests

      def object_class
        ObjectClass
      end

      def test_spy_logs_messages_sent_to_instances_of_a_class
        assert_equal(
          [
            CrispyReceivedMessage[:initialize],
            CrispyReceivedMessage[:initialize],
            CrispyReceivedMessage[:initialize],
            CrispyReceivedMessage[:hoge, 3, 4, 5],
            CrispyReceivedMessage[:private_foo, 3],
            CrispyReceivedMessage[:hoge, 1, 2, 3],
            CrispyReceivedMessage[:private_foo, 1],
            CrispyReceivedMessage[:foo],
            CrispyReceivedMessage[:hoge, 3, 4, 5],
            CrispyReceivedMessage[:private_foo, 3],
            CrispyReceivedMessage[:bar],
            CrispyReceivedMessage[:hoge, 7, 8, 9],
            CrispyReceivedMessage[:private_foo, 7],
            CrispyReceivedMessage[:bar],
          ],
          @subject.received_messages_with_receiver
        )
      end

      def test_spy_has_received_messages_sent_to_an_object
        assert @subject.received?(:hoge)
        assert @subject.received?(:foo)
        assert not(@subject.received?(:baz))
        assert @subject.received?(:private_foo)
      end

      def test_spy_has_received_messages_with_arguments_sent_to_an_object
        assert @subject.received?(:hoge, 1, 2, 3)
        assert @subject.received?(:hoge, 3, 4, 5)
        assert @subject.received?(:private_foo, 1)
        assert @subject.received?(:private_foo, 3)
        assert not(@subject.received?(:hoge, 0, 0, 0))
        assert not(@subject.received?(:private_foo, 0, 0, 0))
        assert not(@subject.received?(:foo, 1))
        assert not(@subject.received?(:bar, nil))
        assert not(@subject.received?(:baz, nil))
      end

      def test_spy_has_received_messages_once_sent_to_an_object
        assert not(@subject.received_once?(:hoge))
        assert not(@subject.received_once?(:private_foo))
        assert not(@subject.received_once?(:hoge, 3, 4, 5))
        assert not(@subject.received_once?(:private_foo, 3))
        assert not(@subject.received_once?(:private_foo, 3, 4))
        assert @subject.received_once?(:foo)
        assert not(@subject.received_once?(:bar))
        assert not(@subject.received_once?(:baz))
      end

      def test_spy_counts_received_messages_sent_to_an_object
        assert_equal(1, @subject.count_received(:hoge, 1, 2, 3))
        assert_equal(2, @subject.count_received(:hoge, 3, 4, 5))
        assert_equal(0, @subject.count_received(:hoge, 0, 0, 0))
        assert_equal(4, @subject.count_received(:hoge))

        assert_equal(1, @subject.count_received(:private_foo, 1))
        assert_equal(2, @subject.count_received(:private_foo, 3))
        assert_equal(0, @subject.count_received(:private_foo, 0))
        assert_equal(4, @subject.count_received(:private_foo))

        assert_equal(1, @subject.count_received(:foo))
        assert_equal(2, @subject.count_received(:bar))
      end

    end

    class TestReceivedMessageWithReceiver < self
      include CommonClassSpyTests

      def object_class
        ObjectClassNonBasic
      end

      class ObjectClassNonBasic

        def hoge a, b, c
          private_foo a
          [a, b, c]
        end
        def foo
          123
        end
        def bar
          []
        end
        def baz
        end
        def method_to_stub1
          'method to stub 1 (before stubbed)'
        end
        def method_to_stub2
          'method to stub 2 (before stubbed)'
        end
        def method_to_stub3
          'method to stub 3 (before stubbed)'
        end

        def private_foo a
          :private_foo
        end
        private :private_foo

      end

      def test_spy_logs_messages_with_receiver_sent_to_instances_of_a_class
        assert_equal(
          [
            CrispyReceivedMessageWithReceiver[@object_instances[0], :initialize],
            CrispyReceivedMessageWithReceiver[@object_instances[1], :initialize],
            CrispyReceivedMessageWithReceiver[@object_instances[2], :initialize],
            CrispyReceivedMessageWithReceiver[@object_instances[0], :hoge, 3, 4, 5],
            CrispyReceivedMessageWithReceiver[@object_instances[0], :private_foo, 3],
            CrispyReceivedMessageWithReceiver[@object_instances[1], :hoge, 1, 2, 3],
            CrispyReceivedMessageWithReceiver[@object_instances[1], :private_foo, 1],
            CrispyReceivedMessageWithReceiver[@object_instances[0], :foo],
            CrispyReceivedMessageWithReceiver[@object_instances[2], :hoge, 3, 4, 5],
            CrispyReceivedMessageWithReceiver[@object_instances[2], :private_foo, 3],
            CrispyReceivedMessageWithReceiver[@object_instances[1], :bar],
            CrispyReceivedMessageWithReceiver[@object_instances[2], :hoge, 7, 8, 9],
            CrispyReceivedMessageWithReceiver[@object_instances[2], :private_foo, 7],
            CrispyReceivedMessageWithReceiver[@object_instances[1], :bar],
          ],
          @subject.received_messages_with_receiver
        )
      end

      def test_spy_has_received_messages_with_receiver_sent_to_an_object
        assert @subject.received_with_receiver?(@object_instances[0], :hoge)
        assert @subject.received_with_receiver?(@object_instances[0], :foo)
        assert not(@subject.received_with_receiver?(@object_instances[0], :baz))
        assert not(@subject.received_with_receiver?(@object_instances[0], :bar))
        assert @subject.received_with_receiver?(@object_instances[0], :private_foo)

        assert @subject.received_with_receiver?(@object_instances[1], :hoge)
        assert not(@subject.received_with_receiver?(@object_instances[1], :foo))
        assert not(@subject.received_with_receiver?(@object_instances[1], :baz))
        assert @subject.received_with_receiver?(@object_instances[1], :bar)
        assert @subject.received_with_receiver?(@object_instances[1], :private_foo)

        assert @subject.received_with_receiver?(@object_instances[2], :hoge)
        assert not(@subject.received_with_receiver?(@object_instances[2], :foo))
        assert not(@subject.received_with_receiver?(@object_instances[2], :baz))
        assert not(@subject.received_with_receiver?(@object_instances[2], :bar))
        assert @subject.received_with_receiver?(@object_instances[2], :private_foo)
      end

      def test_spy_has_received_messages_with_receiver_and_arguments_sent_to_an_object
        assert @subject.received_with_receiver?(@object_instances[0], :hoge, 3, 4, 5)
        assert @subject.received_with_receiver?(@object_instances[0], :private_foo, 3)
        assert not(@subject.received_with_receiver?(@object_instances[0], :hoge, 1, 2, 3))
        assert not(@subject.received_with_receiver?(@object_instances[0], :private_foo, 1))
        assert not(@subject.received_with_receiver?(@object_instances[0], :foo, 1))
        assert not(@subject.received_with_receiver?(@object_instances[0], :bar, nil))

        assert @subject.received_with_receiver?(@object_instances[1], :hoge, 1, 2, 3)
        assert @subject.received_with_receiver?(@object_instances[1], :private_foo, 1)
        assert not(@subject.received_with_receiver?(@object_instances[1], :hoge, 0, 0, 0))
        assert not(@subject.received_with_receiver?(@object_instances[1], :private_foo, 0, 0, 0))
        assert not(@subject.received_with_receiver?(@object_instances[1], :hoge, 3, 4, 5))
        assert not(@subject.received_with_receiver?(@object_instances[1], :private_foo, 3))
        assert not(@subject.received_with_receiver?(@object_instances[1], :foo, 1))
        assert not(@subject.received_with_receiver?(@object_instances[1], :baz, nil))

        assert @subject.received_with_receiver?(@object_instances[2], :hoge, 7, 8, 9)
        assert @subject.received_with_receiver?(@object_instances[2], :private_foo, 7)
        assert @subject.received_with_receiver?(@object_instances[2], :hoge, 3, 4, 5)
        assert @subject.received_with_receiver?(@object_instances[2], :private_foo, 3)
        assert not(@subject.received_with_receiver?(@object_instances[2], :hoge, 1, 2, 3))
        assert not(@subject.received_with_receiver?(@object_instances[2], :private_foo, 1))
        assert not(@subject.received_with_receiver?(@object_instances[2], :hoge, 0, 0, 0))
        assert not(@subject.received_with_receiver?(@object_instances[2], :private_foo, 0, 0, 0))
        assert not(@subject.received_with_receiver?(@object_instances[2], :foo, 1))
        assert not(@subject.received_with_receiver?(@object_instances[2], :bar, nil))
        assert not(@subject.received_with_receiver?(@object_instances[2], :baz, nil))
      end

      def test_spy_has_received_messages_with_receiver_once_sent_to_an_object
        assert @subject.received_once_with_receiver?(@object_instances[0], :hoge)
        assert @subject.received_once_with_receiver?(@object_instances[0], :private_foo)
        assert @subject.received_once_with_receiver?(@object_instances[0], :hoge, 3, 4, 5)
        assert @subject.received_once_with_receiver?(@object_instances[0], :private_foo, 3)
        assert not(@subject.received_once_with_receiver?(@object_instances[0], :hoge, 1, 2, 3))
        assert not(@subject.received_once_with_receiver?(@object_instances[0], :private_foo, 1))
        assert not(@subject.received_once_with_receiver?(@object_instances[0], :private_foo, 3, 4))
        assert @subject.received_once_with_receiver?(@object_instances[0], :foo)
        assert @subject.received_once_with_receiver?(@object_instances[0], :initialize)
        assert not(@subject.received_once_with_receiver?(@object_instances[0], :bar))

        assert @subject.received_once_with_receiver?(@object_instances[1], :hoge)
        assert @subject.received_once_with_receiver?(@object_instances[1], :private_foo)
        assert not(@subject.received_once_with_receiver?(@object_instances[1], :hoge, 3, 4, 5))
        assert not(@subject.received_once_with_receiver?(@object_instances[1], :private_foo, 3))
        assert @subject.received_once_with_receiver?(@object_instances[1], :hoge, 1, 2, 3)
        assert @subject.received_once_with_receiver?(@object_instances[1], :private_foo, 1)
        assert not(@subject.received_once_with_receiver?(@object_instances[1], :private_foo, 1, 2))
        assert not(@subject.received_once_with_receiver?(@object_instances[1], :foo))
        assert @subject.received_once_with_receiver?(@object_instances[1], :initialize)
        assert not(@subject.received_once_with_receiver?(@object_instances[1], :bar))
        assert not(@subject.received_once_with_receiver?(@object_instances[1], :baz))

        assert not(@subject.received_once_with_receiver?(@object_instances[2], :hoge))
        assert not(@subject.received_once_with_receiver?(@object_instances[2], :private_foo))
        assert @subject.received_once_with_receiver?(@object_instances[2], :hoge, 7, 8, 9)
        assert @subject.received_once_with_receiver?(@object_instances[2], :private_foo, 7)
        assert not(@subject.received_once_with_receiver?(@object_instances[2], :hoge, 1, 2, 3))
        assert not(@subject.received_once_with_receiver?(@object_instances[2], :private_foo, 1))
        assert not(@subject.received_once_with_receiver?(@object_instances[2], :private_foo, 1, 2))
        assert not(@subject.received_once_with_receiver?(@object_instances[2], :foo))
        assert @subject.received_once_with_receiver?(@object_instances[2], :initialize)
        assert not(@subject.received_once_with_receiver?(@object_instances[2], :baz))
      end

      def test_spy_counts_received_with_receiver_messages_with_receiver_sent_to_an_object
        assert_equal(1, @subject.count_received_with_receiver(@object_instances[0], :initialize))
        assert_equal(0, @subject.count_received_with_receiver(@object_instances[0], :initialize, 0))
        assert_equal(1, @subject.count_received_with_receiver(@object_instances[0], :hoge))
        assert_equal(1, @subject.count_received_with_receiver(@object_instances[0], :hoge, 3, 4, 5))
        assert_equal(0, @subject.count_received_with_receiver(@object_instances[0], :hoge, 1, 2, 3))
        assert_equal(1, @subject.count_received_with_receiver(@object_instances[0], :private_foo))
        assert_equal(1, @subject.count_received_with_receiver(@object_instances[0], :private_foo, 3))
        assert_equal(0, @subject.count_received_with_receiver(@object_instances[0], :private_foo, 1))
        assert_equal(1, @subject.count_received_with_receiver(@object_instances[0], :foo))
        assert_equal(0, @subject.count_received_with_receiver(@object_instances[0], :bar))

        assert_equal(1, @subject.count_received_with_receiver(@object_instances[1], :initialize))
        assert_equal(0, @subject.count_received_with_receiver(@object_instances[1], :initialize, 1))
        assert_equal(1, @subject.count_received_with_receiver(@object_instances[1], :hoge))
        assert_equal(1, @subject.count_received_with_receiver(@object_instances[1], :hoge, 1, 2, 3))
        assert_equal(0, @subject.count_received_with_receiver(@object_instances[1], :hoge, 3, 4, 5))
        assert_equal(1, @subject.count_received_with_receiver(@object_instances[1], :private_foo))
        assert_equal(1, @subject.count_received_with_receiver(@object_instances[1], :private_foo, 1))
        assert_equal(0, @subject.count_received_with_receiver(@object_instances[1], :private_foo, 3))
        assert_equal(0, @subject.count_received_with_receiver(@object_instances[1], :foo))
        assert_equal(2, @subject.count_received_with_receiver(@object_instances[1], :bar))
        assert_equal(0, @subject.count_received_with_receiver(@object_instances[1], :bar, 9))

        assert_equal(1, @subject.count_received_with_receiver(@object_instances[2], :initialize))
        assert_equal(0, @subject.count_received_with_receiver(@object_instances[2], :initialize, 2))
        assert_equal(2, @subject.count_received_with_receiver(@object_instances[2], :hoge))
        assert_equal(1, @subject.count_received_with_receiver(@object_instances[2], :hoge, 3, 4, 5))
        assert_equal(1, @subject.count_received_with_receiver(@object_instances[2], :hoge, 7, 8, 9))
        assert_equal(0, @subject.count_received_with_receiver(@object_instances[2], :hoge, 1, 2, 3))
        assert_equal(2, @subject.count_received_with_receiver(@object_instances[2], :private_foo))
        assert_equal(1, @subject.count_received_with_receiver(@object_instances[2], :private_foo, 3))
        assert_equal(1, @subject.count_received_with_receiver(@object_instances[2], :private_foo, 7))
        assert_equal(0, @subject.count_received_with_receiver(@object_instances[2], :private_foo, 1))
        assert_equal(0, @subject.count_received_with_receiver(@object_instances[2], :foo))
        assert_equal(0, @subject.count_received_with_receiver(@object_instances[2], :bar))
        assert_equal(0, @subject.count_received_with_receiver(@object_instances[2], :baz))
      end

      def test_spy_raises_error_given_non_symbol_as_method_name
        assert_raises(::TypeError){ @subject.received_with_receiver?(@object_instances[0], nil) }
        assert_raises(::TypeError){ @subject.received_once_with_receiver?(@object_instances[0], nil) }
        assert_raises(::TypeError){ @subject.count_received_with_receiver(@object_instances[0], nil) }
      end

    end

  end

  class TestCrispyDouble < TestCrispy

    def setup
      @expected_hoge = Object.new
      @expected_foo  = Object.new
      @expected_bar  = Object.new
      @expected_baz  = Object.new

      @double = double('some double', hoge: @expected_hoge, foo: @expected_foo)
      @double.stub(bar: @expected_bar, baz: @expected_baz)

      @actual_hoge1 = @double.hoge :with, :any, :arguments do
        'and a block'
      end
      @actual_hoge2 = @double.hoge
      @actual_foo = @double.foo
      @actual_bar = @double.bar
      @actual_baz = @double.baz
    end

    def test_double_can_stub_specified_methods
      assert_same @expected_hoge, @actual_hoge1
      assert_same @expected_hoge, @actual_hoge2
      assert_same @expected_foo, @actual_foo
      assert_same @expected_bar, @actual_bar
      assert_same @expected_baz, @actual_baz
    end

    def test_double_is_spied
      assert spied? @double

      assert_same @double.received_messages, spy(@double).received_messages

      assert @double.received?(:hoge)
      assert @double.received_once?(:hoge, :with, :any, :arguments)
      assert not(@double.received?(:hoge, 0, 0, 0))
      assert not(@double.received_once?(:hoge, 0, 0, 0))
      assert not(@double.received_once?(:hoge))
      assert_equal 0, @double.count_received(:hoge, 0, 0, 0)
      assert_equal 1, @double.count_received(:hoge, :with, :any, :arguments)
      assert_equal 2, @double.count_received(:hoge)

      assert @double.received?(:bar)
      assert @double.received_once?(:bar)

      assert @double.received_once?(:foo)
      assert @double.received?(:foo)
      assert_equal 1, @double.count_received(:foo)

      assert not(@double.received?(:non_used_method))
      assert not(@double.received_once?(:non_used_method))
      assert_equal 0, @double.count_received(:non_used_method)
    end

    def test_double_doesnt_spy_spy_methods
      @double.stub(a: 0)
      @double.received? :hoge
      @double.received_once? :hoge
      @double.count_received :hoge

      should_not_logged = %i[
        received? received_once? count_received
        stub received_messages
      ]

      assert_empty(
        @double.received_messages.select {|received_messages| should_not_logged.include? received_messages.method_name }
      )

    end

  end

end

$VERBOSE = true # enable warnings

require 'crispy'
require_relative 'test_helper'
require 'minitest/autorun'

class TestCrispy < MiniTest::Test
  include ::Crispy

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
      fail "Not stubbed actually! The test fails."
    end
    def method_to_stub2
      fail "Not stubbed actually! The test fails."
    end

    def private_foo a
      :private_foo
    end
    private :private_foo

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

    def setup
      @object = ObjectClass.new

      @returned_spy = spy_into(
        @object, method_to_stub1: :stubbed1, method_to_stub2: :stubbed2
      )

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

    def test_spy_is_also_returned_by_spy_into_method
      assert_same @subject, @returned_spy
    end

  end

  class TestCrispySpyIntoInstances < TestCrispy

    def setup
      @returned_spy = spy_into_instances(
        ObjectClass, method_to_stub1: :stubbed_instance_method1, method_to_stub2: :stubbed_instance_method2
      )

      @subject = spy_of_instances(ObjectClass)
      @object_instances = Array.new(3){ ObjectClass.new }

      @object_instances[0].hoge 3, 4, 5
      @object_instances[1].hoge 1, 2, 3
      @object_instances[0].foo
      @object_instances[2].hoge 3, 4, 5
      @object_instances[1].bar
      @object_instances[2].hoge 7, 8, 9
      @object_instances[1].bar
      @object_instances[0].bar
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
          CrispyReceivedMessage[:bar],
        ],
        @subject.received_messages
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

  end

end

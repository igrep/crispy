require "crispy/version"
require "crispy/spy_wrapper"
require "crispy/double"

if __FILE__ == $PROGRAM_NAME
  $VERBOSE = true

  require 'crispy/spied_message'
  require 'minitest/autorun'

  # Inherit BasicObject because it has fewer meta-programming methods than Object
  class ObjectClass < BasicObject
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
    def method_to_stub1
      fail "Not stubbed actually! The test fails."
    end
    def method_to_stub2
      fail "Not stubbed actually! The test fails."
    end

    private def private_foo a
      :private_foo
    end
  end

  class TestCrispySpyInto < MiniTest::Test

    def setup
      @object = ObjectClass.new

      @subject = Crispy.spy_into(
        @object, method_to_stub1: :stubbed1, method_to_stub2: :stubbed2
      )

      @object.hoge 1, 2, 3
      @object.foo
      @object.hoge 3, 4, 5
    end

    def test_spy_logs_messages_sent_to_an_object
      assert_equal(
        [
          Crispy::SpiedMessage[:hoge, 1, 2, 3],
          Crispy::SpiedMessage[:private_foo, 1],
          Crispy::SpiedMessage[:foo],
          Crispy::SpiedMessage[:hoge, 3, 4, 5],
          Crispy::SpiedMessage[:private_foo, 3],
        ],
        @subject.spied_messages
      )
    end

    def test_spy_has_spied_messages_sent_to_an_object
      assert @subject.spied?(:hoge)
      assert @subject.spied?(:foo)
      assert not(@subject.spied?(:bar))
      assert @subject.spied?(:private_foo)
    end

    def test_spy_has_spied_messages_with_arguments_sent_to_an_object
      assert @subject.spied?(:hoge, 1, 2, 3)
      assert @subject.spied?(:hoge, 3, 4, 5)
      assert @subject.spied?(:private_foo, 1)
      assert @subject.spied?(:private_foo, 3)
      assert not(@subject.spied?(:hoge, 0, 0, 0))
      assert not(@subject.spied?(:private_foo, 0, 0, 0))
      assert not(@subject.spied?(:foo, 1))
      assert not(@subject.spied?(:bar, nil))
    end

    def test_spy_has_spied_messages_once_sent_to_an_object
      assert not(@subject.spied_once?(:hoge))
      assert not(@subject.spied_once?(:private_foo))
      assert @subject.spied_once?(:hoge, 3, 4, 5)
      assert @subject.spied_once?(:private_foo, 3)
      assert not(@subject.spied_once?(:private_foo, 3, 4))
      assert @subject.spied_once?(:foo)
      assert not(@subject.spied_once?(:bar))
    end

    def test_spy_counts_spied_messages_sent_to_an_object
      assert_equal(1, @subject.count_spied(:hoge, 1, 2, 3))
      assert_equal(1, @subject.count_spied(:hoge, 3, 4, 5))
      assert_equal(0, @subject.count_spied(:hoge, 0, 0, 0))
      assert_equal(2, @subject.count_spied(:hoge))

      assert_equal(1, @subject.count_spied(:private_foo, 1))
      assert_equal(1, @subject.count_spied(:private_foo, 3))
      assert_equal(0, @subject.count_spied(:private_foo, 0))
      assert_equal(2, @subject.count_spied(:private_foo))

      assert_equal(1, @subject.count_spied(:foo))
      assert_equal(0, @subject.count_spied(:bar))
    end

    def test_spy_changes_stubbed_method
      assert_equal(:stubbed1, @object.method_to_stub1)
      assert_equal(:stubbed2, @object.method_to_stub2)
    end

    def test_spy_is_accessible_with_crispy_spy_method
      assert_same @subject, Crispy.spy(@object)
    end

  end

  class TestCrispyDouble < MiniTest::Test
    def setup
      @expected_hoge = Object.new
      @expected_foo  = Object.new
      @expected_bar  = Object.new
      @expected_baz  = Object.new

      @double = Crispy.double('some double', hoge: @expected_hoge, foo: @expected_foo)
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

module Crispy
end

class << Crispy

  # Returns a SpyWrapper object to wrap all methods of the object.
  def spy_into object, stubs_map = {}
    self::SpyWrapper.new object, stubs_map
  end

  def double name_or_stubs_map = nil, stubs_map = {}
    self::Double.new name_or_stubs_map, stubs_map
  end

  # Make and returns a Crispy::ClassSpy's instance to spy all instances of a class.
  def spy_on_any_instance_of klass
    raise NotImplementedError, "Sorry, this feature is under construction :("
    self::ClassSpy.new klass
  end

  def spy object
    object.instance_eval { @__CRISPY_SPY__ }
  end

  # Begins to log all instances and its spied messages of a class.
  # _NOTE_: replace the constant containing the class
  def spy_into_class! klass
    raise NotImplementedError, "Sorry, this feature is under construction :("
    spy_class = spy_on_any_instance_of klass
    stub_const! klass.name, spy_class
    spy_class
  end

  def stub_const! const_name, value
    raise NotImplementedError, "Sorry, this feature is under construction :("
  end

end

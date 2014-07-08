require "crispy/version"
require "crispy/spy"
require "crispy/object_spy"
require "crispy/spy_extension"
require "crispy/stubber"

if __FILE__ == $PROGRAM_NAME

  require 'crispy/spied_message'
  require 'minitest/autorun'

  class TestCrispySpyOn < MiniTest::Test

    class ObjectClass
      def hoge a, b, c
        [a, b, c]
      end
      def foo
        123
      end
      def bar
        []
      end
    end

    def setup
      @object = ObjectClass.new

      @subject = Crispy.spy_on @object

      @subject.hoge 1, 2, 3
      @subject.foo
      @subject.hoge 3, 4, 5
    end

    def test_spy_logs_messages_sent_to_an_object
      assert_equal(
        [
          Crispy::SpiedMessage[:hoge, 1, 2, 3],
          Crispy::SpiedMessage[:foo],
          Crispy::SpiedMessage[:hoge, 3, 4, 5],
        ],
        @subject.spied_messages
      )
    end

    def test_spy_has_spied_messages_sent_to_an_object
      assert @subject.spied?(:hoge)
      assert @subject.spied?(:foo)
      assert not(@subject.spied?(:bar))
    end

    def test_spy_has_spied_messages_with_arguments_sent_to_an_object
      assert @subject.spied?(:hoge, 1, 2, 3)
      assert @subject.spied?(:hoge, 3, 4, 5)
      assert not(@subject.spied?(:hoge, 0, 0, 0))
      assert not(@subject.spied?(:foo, 1))
      assert not(@subject.spied?(:bar, nil))
    end

    def test_spy_has_spied_messages_once_sent_to_an_object
      assert not(@subject.spied_once?(:hoge))
      assert @subject.spied_once?(:hoge, 3, 4, 5)
      assert @subject.spied_once?(:foo)
      assert not(@subject.spied_once?(:bar))
    end

    def test_spy_counts_spied_messages_sent_to_an_object
      assert_equal(1, @subject.count_spied(:hoge, 1, 2, 3))
      assert_equal(1, @subject.count_spied(:hoge, 3, 4, 5))
      assert_equal(0, @subject.count_spied(:hoge, 0, 0, 0))
      assert_equal(2, @subject.count_spied(:hoge))
      assert_equal(1, @subject.count_spied(:foo))
      assert_equal(0, @subject.count_spied(:bar))
    end

    def test_spy_does_not_change_objects_behavior
      assert_equal(@object.hoge('a', 'b', 'c'), @subject.hoge('a', 'b', 'c'))
      assert_equal(@object.foo, @subject.foo)
      assert_equal(@object.bar, @subject.bar)
      assert_equal(@object.object_id, @subject.object_id)
      assert_equal(@object.class, @subject.class)
    end

  end
end

module Crispy
end

class << Crispy

  # Make and returns a Crispy::ObjectSpy's instance to log all spied messages of an object.
  def spy_on object
    self::ObjectSpy.new object
  end

  # Make and returns a Crispy::ClassSpy's instance to spy all instances of a class.
  def spy_on_any_instance_of klass
    self::ClassSpy.new klass
  end

  # Returns a Crispy::Spy's instance.
  def spy
    self::Spy.new
  end

  def stubber object
    self::Stubber.new object
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
  end

end

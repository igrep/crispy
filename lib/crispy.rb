require "crispy/version"
require "crispy/spy"
require "crispy/object_spy"

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
  @registered_spies = []
end

class << Crispy

  # Make and returns a Crispy::ObjectSpy's instance to log all spied messages of an object.
  def spy_on object
    spy = self::ObjectSpy.new object
    @registered_spies << spy
    spy
  end

  # Returns a Crispy::Spy's instance.
  def spy
    spy = self::Spy.new
    @registered_spies << spy
    spy
  end

  # Begins to log all instances and its spied messages of a class.
  # _NOTE_: rewrites the +new+ method of the given class.
  def spy_into_class klass
    raise NotImplementedError, "Sorry, this feature is under construction :("
  end

  def erase_all_spied_logs
    @registered_spies.each {|spy| self.erase_memories_of spy }
  end

  def erase_spied_logs_of spy_or_class
    case spy_or_class
    when self::Spyable
      spy_or_class.spied_messages.clear
    when ::Class
      raise NotImplementedError, "Sorry, this feature is under construction :("
    end
  end

end

require 'spec_helper'
require 'rspec/crispy'

RSpec.configure do|config|
  config.mock_with(:rspec)
  ::RSpec::Crispy.configure_without_conflict config
end

class ObjectClass

  CONSTANT_TO_STUB = ::Crispy.double('value_before_stubbed')

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

RSpec.describe ::RSpec::Crispy do

  context 'when including' do
    include ::RSpec::Crispy::CrispyFeatures

    describe '#spy_into' do
      it 'makes a Crispy\'s spy.' do
        expect(spy_into(Object.new)).to be_instance_of ::Crispy::CrispyInternal::Spy
      end
    end

    describe '#spy_into_instances' do
      it 'makes a Crispy\'s class spy.' do
        expect(spy_into_instances(Class.new)).to be_instance_of ::Crispy::CrispyInternal::ClassSpy
      end
    end

    describe '#spy' do
      it 'returns a Crispy\'s spy.' do
        object = Object.new
        spy_into(object)
        expect(spy(object)).to be_instance_of ::Crispy::CrispyInternal::Spy
      end
    end

    describe '#spy_of_instances' do
      it 'returns a Crispy\'s class spy.' do
        klass = Class.new
        spy_into_instances klass
        expect(spy_of_instances(klass)).to be_instance_of ::Crispy::CrispyInternal::ClassSpy
      end
    end

    describe '#double' do
    end

    describe '#have_received' do
    end

    describe '#have_received_once' do
    end
  end

  context 'when not including' do

    describe '#spy' do
    end

    describe '#double' do
    end

    describe '#have_received' do
    end

  end

end

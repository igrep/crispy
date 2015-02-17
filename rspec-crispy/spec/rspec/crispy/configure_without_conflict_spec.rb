require 'spec_helper'
require 'rspec/crispy'

RSpec.configure do|config|
  config.mock_with(:rspec)
  ::RSpec::Crispy.configure_without_conflict config
end

class ObjectClass

  CONSTANT_TO_STUB = ::Crispy.double('value_before_stubbed')

  def instance_hoge _, _, _
  end
  def instance_foo
  end
  def instance_never_called *_arguments
  end

  def self.hoge a, b, c
    private_foo a
    [a, b, c]
  end
  def self.foo
    123
  end

  def self.never_called *_arguments
    fail 'You should not call this method!'
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

  def self.private_foo _
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
      it 'returns a Crispy\'s double.' do
        expect(double('name')).to be_instance_of ::Crispy::CrispyInternal::Double
      end
    end

    shared_examples_for 'doesn\'match and then produces failure_message' do
      it 'doesn\'t match' do
        expect(result).to be false
      end

      it 'it produces failure_message' do
        # The received message should be checked by your own eyes. Is it easy to read?
        puts subject.failure_message
      end
    end

    describe '#have_received' do
      let!(:non_used_object){ ObjectClass.new }
      before do
        spy_into(ObjectClass)
        ObjectClass.hoge 1, 1, 1
        ObjectClass.hoge 2, 2, 2

        spy_into(non_used_object)
      end

      subject { have_received(method_name, *arguments) }

      context 'without arguments' do
        let(:arguments){ [] }

        context 'given a method ObjectClass actually called' do
          let(:method_name){ :hoge }

          it { is_expected.to be_matches(ObjectClass) }

          context 'given an object spy_into-ed but not used as matches?\'s argument' do
            let!(:result){ subject.matches? non_used_object }

            it_should_behave_like 'doesn\'match and then produces failure_message'

            it 'its failure_message tells the subject has received no messages' do
              expect(subject.failure_message).to include("Actually, it has received no messages.\n")
            end

          end

        end

        context 'given a method ObjectClass didn\'t call' do
          let(:method_name){ :never_called }
          let!(:result){ subject.matches? ObjectClass }

          it_should_behave_like 'doesn\'match and then produces failure_message'

          it 'its failure_message tells ObjectClass\'s received messages' do
            expect(subject.failure_message).to(
              include('hoge(1, 1, 1)') & include('hoge(2, 2, 2)')
            )
          end

        end

      end

      context 'with arguments' do

        context 'given a method and arguments ObjectClass actually called' do
          let(:method_name){ :hoge }
          let(:arguments){ [1, 1, 1] }

          it { is_expected.to be_matches(ObjectClass) }
        end

        context 'given a method ObjectClass actually called, and not received arguments' do
          let(:method_name){ :hoge }
          let(:arguments){ [3, 3, 3] }
          let!(:result){ subject.matches? ObjectClass }

          it_should_behave_like 'doesn\'match and then produces failure_message'
        end

      end

    describe '#have_received_once' do
    end

    describe '#expect_any_instance_of' do
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

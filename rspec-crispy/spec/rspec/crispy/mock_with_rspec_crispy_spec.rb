require 'spec_helper'
require 'rspec/crispy'

RSpec.configure do|config|
  config.mock_with ::RSpec::Crispy
end

class SomeClass

  SOME_CONSTANT = 'not stubbed'

end

RSpec.describe ::RSpec::Crispy do

  describe '#spy' do
  end

  describe '#double' do
  end

  describe '#have_received' do
  end

  describe '#have_received_once' do
  end

  describe '#stub_const' do

    context 'when stubs' do
      before do
        spy_into(::Crispy::CrispyInternal::ConstChanger)

        stub_const 'SomeClass::SOME_CONSTANT', 'stubbed'
      end

      it 'mutates the value of constant' do
        expect(SomeClass::SOME_CONSTANT).to eq 'stubbed'
      end

      it 'calls ::Crispy::CrispyInternal::ConstChanger.change_by_full_name' do
        expect(spy(::Crispy::CrispyInternal::ConstChanger).received?(:change_by_full_name, 'SomeClass::SOME_CONSTANT', 'stubbed')).to be true
      end

    end

    context 'when not stubs' do
      it 'doesn\'t mutate the value of constant' do
        expect(SomeClass::SOME_CONSTANT).to eq 'not stubbed'
      end
    end

  end

end

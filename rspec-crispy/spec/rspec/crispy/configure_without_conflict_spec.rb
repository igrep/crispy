require 'spec_helper'
require 'rspec/crispy'

RSpec.configure do|config|
  config.mock_with(:rspec)
  ::RSpec::Crispy.configure_without_conflict config
end

RSpec.describe ::RSpec::Crispy do

  context 'when including' do
    include ::RSpec::Crispy::CrispyFeatures

    describe '#spy_into' do
      it 'makes a spy once.' do
        spy_into(::Crispy::CrispyInternal::Spy)
        spy_into(Object.new)
        expect(spy(::Crispy::CrispyInternal::Spy).count_received :new).to eq 1
      end
    end

    describe '#spy' do
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

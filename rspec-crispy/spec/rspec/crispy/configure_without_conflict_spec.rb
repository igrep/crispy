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
      it 'makes a Crispy\'s spy.' do
        expect(spy_into(Object.new)).to be_instance_of ::Crispy::CrispyInternal::Spy
      end
    end
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

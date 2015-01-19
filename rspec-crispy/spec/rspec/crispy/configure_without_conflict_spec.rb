require 'spec_helper'
require 'rspec/crispy'

RSpec.configure do|config|
  config.mock_with(:rspec)
  ::RSpec::Crispy.configure_without_conflict config
end

RSpec.describe ::RSpec::Crispy do
  before do
    ::Crispy.spy_into_instances ::Crispy # spy module functions of Crispy
  end

  context 'when including' do
    include ::RSpec::Crispy::CrispyFeatures

    describe '#spy_into' do
    end

    describe '#spy' do
      it 'calls ::Crispy.spy once.' do
        spy_into(::Crispy)
        spy(::Crispy)
        expect(spy_of_instances(::Crispy).count_received :spy).to eq 1
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

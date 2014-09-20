describe GreatClass do
  describe 'some_subject_method' do
    subject { described_class.new }
    before do
      spy_into SomeModule, some_important_method: 'stubbed_value'
      subject.some_subject_method
    end
    it 'makes itself special!' do
      is_expected.to be_some_special_state 
    end
    it 'remembers to do the important thing!' do
      expect(spy(SomeModule).received(:some_important_method)).to be true
    end
  end
end

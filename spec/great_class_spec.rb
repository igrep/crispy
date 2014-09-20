describe GreatClass do
  describe 'some_subject_method' do
    subject { described_class.new }
    before do
      allow(SomeModule).to receive(:some_important_method).and_return 'stubbed_value'
      subject.some_subject_method
    end
    it 'makes itself special!' do
      is_expected.to be_some_special_state 
    end
    it 'remembers to do the important thing!' do
      expect(SomeModule).to receive(:some_important_method)
      subject.some_subject_method
    end
  end
end

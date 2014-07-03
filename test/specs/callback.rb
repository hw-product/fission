describe Fission::Callback do

  before do
    @source = Carnivore::Source::Spec.new(:name => :tester)
    @callback = Fission::Callback.new('test', @source)
    @callback.extend(Jackal::Utils::Spec::CallbackLocal)
    @message = @source.format(Fission::Utils.new_payload(:tester, :tester => true))
  end

  let(:source){ @source }
  let(:callback){ @callback }
  let(:source_message){ @message }

  describe 'Validity Check' do

    it 'should return valid by default' do
      callback.valid?(source_message).must_equal true
    end

    it 'should return invalid after completed' do
      callback.completed(callback.unpack(source_message), source_message)
      callback.valid?(source_message).must_equal true
    end

    it 'should provide message payload to block on yield' do
      persist = nil
      callback.valid?(source_message) do |payload|
        payload.must_be_kind_of Smash
      end
    end

    it 'should return invalid by default if block is false' do
      result = callback.valid?(source_message) do |payload|
        payload.get(:data, :tester) == :foobar
      end
      result.must_equal false
    end

    it 'should return valid by default if block is true' do
      result = callback.valid?(source_message) do |payload|
        payload.get(:data, :tester) == true
      end
      result.must_equal true
    end

    it 'should return invalid if block is true and completed' do
      callback.completed(callback.unpack(source_message), source_message)
      callback.valid?(source_message) do |payload|
        payload.get(:data, :tester) == :foobar
      end.must_equal false
    end

  end

end

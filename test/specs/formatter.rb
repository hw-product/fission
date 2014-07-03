describe Fission::Formatter do

  before{ @fmt = Fission::Formatter.new({}) }
  let(:fmt){ @fmt }

  it 'should return provided payload' do
    fmt.data.must_equal Hash.new
  end

  it 'should return default type' do
    fmt.type.must_equal :default
  end

  it 'should raise when requesting data' do
    ->{ fmt.data_for(:something) }.must_raise(NotImplementedError)
  end

  it 'should raise when requesting data via #format of unknown source' do
    ->{ Fission::Formatter.format(:something, :fubar, {}) }.must_raise(NameError)
  end

  describe Fission::Formatter::Github do

    before do
      @gh = Fission::Formatter::Github.new(
        payload_for(:github, :nest => :github),
        :create
      )
    end
    let(:gh){ @gh }

    it 'should return repository information' do
      flunk 'TODO: payload needs to be public'
      gh.data_for(:repository).must_be_instance_of Hash
    end

  end

end

require 'spec_helper'

describe Fission::Supervisor do

  let(:supervisor) { Fission::Supervisor.new }
  it "should be a ActorProxy even though it's a SupervisionGroup" do
    supervisor.should be_an_instance_of Celluloid::ActorProxy
  end
  
    
  describe '#supervise_worker' do
  end

  describe '#initial_spawn' do
  end

end

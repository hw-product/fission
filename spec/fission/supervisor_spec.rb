require 'spec_helper'

describe Fission::Supervisor do
  let(:supervisor) { Fission::Supervisor.new }

  describe '#initialize' do
    it 'should be a celluloid actor' do
      supervisor.should be_a_kind_of(Celluloid)
    end

    it 'should not be a supervision group because they are broken' do
      supervisor.should_not be_a_kind_of(Celluloid::SupervisionGroup)
    end
  end

  describe '#workers' do
    it 'should be an empty hash at first' do
      supervisor.workers.should be_a_kind_of(Hash)
    end
  end

  describe '#create_worker' do
  end


end

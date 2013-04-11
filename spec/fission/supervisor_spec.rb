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

  describe '#generate_actor_name' do
  end

  describe '#klass_for_worker' do
    let(:class_name) { "Web" }
  end

  describe '#supervise' do
  end

  describe '#initial_spawn' do
  end

end

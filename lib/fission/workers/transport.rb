require 'forwardable'

module Fission
  class Worker::Transport < Worker

    extend Forwardable

    def_delegators :@mailbox, :<<, :receive, :enqueue, :dequeue

    attr_reader :mailbox
    
    def initialize
      info 'Transport worker starting up, initializing mailbox'
      @mailbox = Celluloid::Mailbox.new
    end

    def terminate
      @mailbox.shutdown
    end

  end
end

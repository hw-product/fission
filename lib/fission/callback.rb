require 'carnivore/callback'
require 'fission/utils'

module Fission
  class Callback < Carnivore::Callback

    include Fission::Utils::Transmission
    include Fission::Utils::MessageUnpack
    include Fission::Utils::Payload

    def valid?(message)
      m = unpack(message)
      if(block_given?)
        !m[:complete].include?(name) && yield(m)
      else
        !m[:complete].include?(name)
      end
    end

    def forward(payload)
      if(payload[:job])
        if(payload[:complete].include?(payload[:job]))
          final_worker = Carnivore::Config.get(:fission, :finalizer)
          if(final_worker)
            debug "Finalizing payload! Finalizer worker: #{final_worker} - payload: #{payload.inspect}"
            transmit(final_worker, payload)
          else
            warn "No finalizer defined for payload! Payload complete: #{payload.inspect}"
          end
        else
          transmit(payload[:job], payload)
        end
      else
        abort ArgumentError.new('No job type provided in payload!')
      end
    end

    def process_manager
      Celluloid::Actor[:process_manager] || abort(NameError.new('No process manager found!'))
    end

    def completed(payload, message=nil)
      payload[:complete].push(name).uniq!
      message.confirm! if message
      debug "This callback has reached completed state on payload: #{payload}"
      forward(payload)
    end

  end
end

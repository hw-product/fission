require 'carnivore/callback'
require 'fission/utils'

module Fission
  class Callback < Carnivore::Callback

    include Fission::Utils::Transmission
    include Fission::Utils::MessageUnpack
    include Fission::Utils::Payload

    # message:: Carnivore::Message
    # Return if message is valid for this callback
    def valid?(message)
      m = unpack(message)
      if(block_given?)
        !m[:complete].include?(name) && yield(m)
      else
        !m[:complete].include?(name)
      end
    end

    # payload:: Hash - message payload
    # Forwards to appropriate worker based on `:job` entry
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

    # Returns `ProcessManager` actor if available. Otherwise aborts
    # TODO: Needs proper linking to allow supervision
    def process_manager
      Celluloid::Actor[:process_manager] || abort(NameError.new('No process manager found!'))
    end

    # payload:: Hash payload
    # message:: Carnivore::Message instance
    # Set completed for callback
    def completed(payload, message)
      payload[:complete].push(name).uniq!
      message.confirm!
      debug "This callback has reached completed state on payload: #{payload}"
      forward(payload)
    end

    # name:: Name of job completed
    # payload:: Hash payload
    # message:: Carnivore::Message instance
    # Set the job name as completed. This will prevent further
    # delivery to the source and invoke the finalizer. Will also push
    # through `#completed` to do callback completion tracking and
    # message confirmation
    def job_completed(name, payload, message)
      payload[:complete].push(name.to_s).uniq!
      completed(payload, message)
    end

    # payload:: Hash payload
    # message:: Carnivore::Message instance
    # Send payload to error handler
    def error(payload, message, reason='No message provided')
      payload[:error] ||= {}
      payload[:error][:callback] = name
      payload[:error][:reason] = reason
      endpoint = Carnivore::Config.get(:fission, :error_handler) ||
        Carnivore::Config.get(:fission, :finalizer)
      if(endpoint)
        Celluloid::Actor[endpoint.to_sym].transmit(payload)
      else
        error "Payload of #{message} resulted in error state. No handler defined: #{payload.inspect}"
      end
    end

  end
end

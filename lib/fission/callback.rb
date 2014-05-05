require 'fission'

module Fission
  class Callback < Carnivore::Callback

    include Fission::Utils::Transmission
    include Fission::Utils::MessageUnpack
    include Fission::Utils::Payload
    include Fission::Utils::NotificationData
    include Fission::Utils::Github
    include Fission::Utils::Inspector

    # message:: Carnivore::Message
    # Return if message is valid for this callback
    def valid?(message)
      m = unpack(message)
      if(m[:complete])
        if(block_given?)
          !m[:complete].include?(name) && yield(m)
        else
          !m[:complete].include?(name)
        end
      else
        block_given? ? yield(m) : true
      end
    end

    # payload:: Hash - message payload
    # Forwards to appropriate worker based on `:job` entry
    def forward(payload)
      if(payload[:job])
        if(payload[:complete].include?(payload[:job]))
          final_worker = Carnivore::Config.get(:fission, :handlers, :complete)
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
      async.store_payload(payload)
      completed(payload, message)
      if(name.to_s == payload[:job])
        call_finalizers(payload, message)
      end
    end

    # payload:: Hash payload
    # state:: Final state (:complete / :error)
    # Transmit payload to any configured finalizers
    # NOTE: At this point the payload will be modified and transmitted
    # async to all finalizers
    def call_finalizers(payload, message, state=:complete)
      if(payload[:frozen])
        error "Attempted finalization of frozen payload. This should not happen! #{message} - #{payload.inspect}"
      else
        begin
          finalizers = Carnivore::Config.get(:fission, :handlers, state)
          finalizers = [finalizers].flatten.compact
          unless(finalizers.empty?)
            [finalizers].flatten.compact.each do |endpoint|
              payload[:complete].delete_if do |component|
                component.start_with?(endpoint)
              end
              payload[:job] = endpoint
              payload[:frozen] = true
              begin
                transmit(endpoint, payload)
              rescue => e
                error "Completed transmission failed to endpoint: #{endpoint} - #{e.class}: #{e}"
              end
            end
          else
            warn "Payload of #{message} reached completed state. No handler defined: #{payload.inspect}"
          end
        rescue => e
          error "!!! Unexpected error encountered in finalizers! Consuming exception and killing payload for #{message}"
          error "!!! Exception encountered: #{e.class}: #{e}"
          debug "{e.class}: #{e}\n#{e.backtrace.join("\n")}"
        end
      end
    end

    # payload:: Hash payload
    # message:: Carnivore::Message instance
    # Send payload to error handler
    def failed(payload, message, reason='No message provided')
      message.confirm!
      payload[:error] ||= {}
      payload[:error][:callback] = name
      payload[:error][:reason] = reason
      call_finalizers(payload, message, :error)
    end

    # job:: name of job/component to check
    # payload:: Payload
    # Check if given job has been completed
    def completed?(job, payload)
      payload.map do |item|
        item.downcase.gsub(':', '_')
      end.include?(job.to_s.downcase.gsub(':', '_'))
    end

    # payload:: message payload
    # If data is enabled, store payload
    def store_payload(payload)
      if(enabled?(:data))
        job = Fission::Data::Job.find_by_message_id(payload[:message_id])
        if(job)
          job.payload = payload
          job.save
        end
      end
    end

    # message:: Original message
    # Executes block and catches unexpected exceptions if encountered
    def failure_wrap(message)
      abort 'Failure wrap requires block for execution' unless block_given?
      begin
        payload = unpack(message)
        yield payload
      rescue => e
        error "!!! Unexpected failure encountered -> #{e.class}: #{e}"
        debug "#{e.class}: #{e}\n#{(e.backtrace || []).join("\n")}"
        failed(payload, message, e.message)
      end
    end

  end
end

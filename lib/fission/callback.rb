require 'fission'

module Fission
  # Customized callback for fission
  class Callback < Jackal::Callback

    include Fission::Utils::ObjectCounts
    include Fission::Utils::Transmission
    include Fission::Utils::MessageUnpack
    include Fission::Utils::Payload
    include Fission::Utils::NotificationData
    include Fission::Utils::Github
    include Fission::Utils::Inspector

    # Validity of message
    #
    # @param message [Carnivore::Message]
    # @return [Truthy, Falsey]
    def valid?(message)
      m = object_counter(:valid_unpack){ unpack(message) }
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

    # Forward payload to worker defined by :job
    #
    # @param payload [Hash]
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

    # Process manager
    #
    # @return [Fission::Utils::Process]
    # @raise [NameError]
    def process_manager
      Celluloid::Actor[:process_manager] || abort(NameError.new('No process manager found!'))
    end

    # Set payload as completed for this callback
    #
    # @param payload [Hash]
    # @param message [Carnivore::Message]
    def completed(payload, message)
      payload[:complete].push(name).uniq!
      message.confirm!
      debug "This callback has reached completed state on payload: #{payload}"
      forward(payload)
    end

    # Set job as completed. Prevents further processing on attached
    # source and invokes the finalizer.
    #
    # @param name [String, Symbol] name of completed (source/callback)
    # @param payload [Hash]
    # @param message [Carnivore::Message]
    def job_completed(name, payload, message)
      payload[:complete].push(name.to_s).uniq!
      async.store_payload(payload)
      completed(payload, message)
      if(name.to_s == payload[:job])
        call_finalizers(payload, message)
      end
    end

    # Transmit payload to finalizers
    #
    # @param payload [Hash]
    # @param message [Carnivore::Message]
    # @param state [Symbol]
    # @note payload will be set as frozen and sent async to finalizers
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

    # Set message as failed and initiate finalizers
    #
    # @param payload [Hash]
    # @param message [Carnivore::Message]
    def failed(payload, message, reason='No message provided')
      message.confirm!
      payload[:error] ||= {}
      payload[:error][:callback] = name
      payload[:error][:reason] = reason
      call_finalizers(payload, message, :error)
    end

    # Job has been completed on payload
    #
    # @param job [String, Symbol]
    # @param payload [Hash]
    # @return [TrueClass, FalseClass]
    def completed?(job, payload)
      payload.map do |item|
        item.downcase.gsub(':', '_')
      end.include?(job.to_s.downcase.gsub(':', '_'))
    end

    # Store payload in persistent data store if available
    #
    # @param payload [Hash]
    # @return [TrueClass, NilClass] true if saved
    def store_payload(payload)
      if(enabled?(:data))
        job = Fission::Data::Job.find_by_message_id(payload[:message_id])
        if(job)
          job.payload = payload
          job.save
          true
        end
      end
    end

  end
end

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

    # Create new instance
    #
    # @return [self]
    def initialize(*_)
      super
      @formatters = Fission::PayloadFormatter.descendants.map do |klass|
        klass.new
      end
    end

    # @return [Carnivore::Config] global configuration
    def global_config
      Carnivore::Config
    end

    # Fetch configuration for namespace
    #
    # @param key [String, Symbol]
    # @return [Smash, NilClass]
    def config_for(key)
      global_config.get(key)
    end

    # @return [Smash] fission namespace configuration
    def fission_config
      config_for(:fission)
    end

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
          info "Payload has reached completed state! (Message ID: #{payload[:message_id]})"
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
      apply_formatters!(payload)
      completed(payload, message)
      if(name.to_s == payload[:job])
        call_finalizers(payload, message)
      end
    end

    # Automatically apply formatters required based on
    # current source and defined destinations
    def apply_formatters!(payload)
      formatters.each do |formatter|
        route = payload.fetch(:data, :router, :route, []).map(&:to_sym)
        if(formatter.source == service_name && route.include?(formatter.destination))
          formatter.format(payload)
        end
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
          payload[:status] = state
          payload[:frozen] = true
          unless(finalizers.empty?)
            [finalizers].flatten.compact.each do |endpoint|
              payload[:complete].delete_if do |component|
                component.start_with?(endpoint)
              end
              payload[:job] = endpoint
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
        Fission::Data::Models::Job.create(
          :message_id => payload[:message_id],
          :payload => payload,
          :account_id => payload.fetch(:data, :account, :id, 1)
        )
        true
      end
    end

  end
end

# Remap Jackals to Fission
Jackal::Callback = Fission::Callback

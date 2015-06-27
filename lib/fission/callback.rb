require 'fission'

module Fission
  # Customized callback for fission
  class Callback < Jackal::Callback

    # Default secret used when grouping is unavailable (dev)
    DEFAULT_SECRET = 'fission-default-secret'

    include Fission::Utils::ObjectCounts
    include Fission::Utils::Transmission
    include Fission::Utils::MessageUnpack
    include Fission::Utils::Payload
    include Fission::Utils::NotificationData
    include Fission::Utils::Github
    include Fission::Utils::Inspector

    # @return [Smash] user configuration information
    attr_accessor :user_configuration

    # Create new instance
    #
    # @return [self]
    def initialize(*_)
      super
      enabled_formatters = config.fetch(:formatters, :enabled,
        app_config.get(:formatters, :enabled)
      )
      disabled_formatters = (
        config.fetch(:formatters, :disabled, []) +
        app_config.fetch(:formatters, :disabled, [])
      ).uniq
      @formatters = Fission::Formatter.descendants.map do |klass|
        next if disabled_formatters.include?(klass.to_s)
        if(enabled_formatters)
          next unless enabled_formatters.include?(klass.to_s)
        end
        debug "Enabling payload formatter: #{klass}"
        klass.new(self)
      end
    end

    # @return [Carnivore::Config] global configuration
    def global_config
      Carnivore::Config
    end

    # @return [Fission::Assets::Store]
    def asset_store
      memoize(:asset_store) do
        require 'fission-assets'
        Fission::Assets::Store.new
      end
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

    # @return [Smash] service configuration
    def config
      result = super
      if(user_configuration)
        result.deep_merge(user_configuration)
      else
        result
      end
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
    def forward(payload, source=nil)
      apply_formatters!(payload)
      if(payload[:job])
        if(payload[:complete].include?(payload[:job]))
          info "Payload has reached completed state! (Message ID: #{payload[:message_id]})"
        else
          if(payload[:frozen])
            info "Payload is frozen and will not be forwarded! (Message ID: #{payload[:message_id]})"
          else
            unless(source)
              source = destination(:output, payload)
            end
            transmit(source, payload)
          end
        end
      else
        abort ArgumentError.new('No job type provided in payload!')
      end
    end

    # Process manager
    #
    # @return [Fission::Utils::Process]
    # @raise [NameError]
    # def process_manager
    #   Celluloid::Actor[:process_manager] || abort(NameError.new('No process manager found!'))
    # end

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
      completed(payload, message)
      if(name.to_s == payload[:job])
        call_finalizers(payload, message)
      end
    end

    # Automatically apply formatters required based on
    # current source and defined job
    def apply_formatters!(payload)
      route = payload.fetch(:data, :router, :route, []).map(&:to_sym)
      formatters.each do |formatter|
        next if payload.fetch(:formatters, []).include?(formatter.class.name)
        s_checksum = payload.checksum
        begin
          if([service_name, '*'].include?(formatter.source) && payload[:job].to_sym == formatter.destination)
            debug "Direct destination matched formatter! (<#{formatter.class}> - #{payload[:id]})"
            formatter.format(payload)
          elsif(route.include?(formatter.destination))
            debug "Route destination matched formatter! (<#{formatter.class}> - #{payload[:id]})"
            formatter.format(payload)
          end
          unless(s_checksum == payload.checksum)
            info "Formatter modified payload and will not be applied again (<#{formatter.class}> - #{payload[:id]})"
            payload[:formatters].push(formatter.class.name)
          end
        rescue => e
          error "Formatter failed <#{formatter.source}:#{formatter.destination}> #{e.class}: #{e}"
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
          apply_formatters!(payload)
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

    # Return name of destination endpoint. This is an override of the
    # Jackal implementation to allow expected behavior of jackal
    # services within Fission where intput/output sources do not exist
    #
    # @param direction [String, Symbol] direction of transmission (:input, :output, :error)
    # @param payload [Smash]
    # @return [Symbol]
    # @note this will generally just provide the job name as
    #   destination. if the router is in use and :input direction is
    #   requested it will attempt to loop to current router action
    def destination(direction, payload)
      if(direction.to_sym == :input)
        (payload.fetch(:data, :router, :route, []).first || payload[:job]).to_sym
      else
        payload[:job].to_sym
      end
    end

    # Extend jackal's failure wrapping to inject configuration into
    # run state provided via payload if available
    #
    # @param message [Carnivore::Message]
    # @return [Object]
    def failure_wrap(message)
      apply_user_config(message) do
        super do |payload|
          result = yield payload
          clean_working_directory(payload)
          result
        end
      end
    end

    # If payload contains account configuration overrides and an
    # override hash is provided for this service, merge into
    # configuration to allow implicit user configuration
    #
    # @param message [Carnivore::Message]
    # @return [Object]
    def apply_user_config(message)
      payload = unpack(message)
      begin
        if(payload.get(:data, :account, :config))
          unpacked_config = Fission::Utils::Cipher.decrypt(
            payload.get(:data, :account, :config),
            :iv => payload[:message_id],
            :key => app_config.fetch(:grouping, DEFAULT_SECRET)
          )
          unpacked_config = MultiJson.load(unpacked_config).to_smash
          if(unpacked_config[service_name])
            self.user_configuration = unpacked_config[service_name]
          end
        end
        yield
      ensure
        self.user_configuration = nil
      end
    end

    # Generate a payload specific working directory
    #
    # @param payload [Smash]
    # @return [String] path
    def working_directory(payload=nil)
      path = File.join(
        config.fetch(
          :working_directory,
          File.join('/tmp/fission', service_name.to_s)
        ),
        payload ? payload[:message_id] : ''
      )
      FileUtils.mkdir_p(path)
      path
    end

    # Remove working directory if it exists
    #
    # @param payload [Smash]
    def clean_working_directory(payload)
      unless(payload[:message_id].to_s.empty?)
        dir_path = File.join(
          config.fetch(
            :working_directory,
            File.join('/tmp/fission', service_name.to_s)
          ),
          payload[:message_id]
        )
        if(File.exists?(dir_path))
          debug "Scrubbing working directory: #{dir_path}"
          FileUtils.rm_rf(dir_path)
        end
      end
      payload
    end

  end
end

# Remap Jackals to Fission
Jackal.send(:remove_const, :Callback)
Jackal::Callback = Fission::Callback

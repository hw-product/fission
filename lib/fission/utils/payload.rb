module Fission
  module Utils

    # Payload helper methods
    module Payload

      # Create a new payload. Sets provided payload into :data and
      # populates the :job and :message_id items.
      #
      # @param job [String, Symbol] name of job
      # @param payload [Hash, String] will attempt JSON load of string
      # @param args [Symbol] argument list options
      # @option args [Symbol] :json_required fail if String provided and is not JSON
      # @return [Hash]
      def new_payload(job, payload, *args)
        if(payload.is_a?(String))
          begin
            payload = MultiJson.load(payload)
          rescue MultiJson::DecodeError
            if(args.include?(:json_required))
              raise
            else
              warn 'Failed to convert payload from string to class. Setting as string value'
              debug "Un-JSONable string: #{payload.inspect}"
            end
          end
        end
        message_id = Zoidberg.uuid
        {
          :job => job,
          :name => job,
          :message_id => message_id,
          :id => message_id,
          :data => payload,
          :complete => [],
          :formatters => [],
          :status => 'active' # error/complete
        }.to_smash
      end

      # Generate a common set of environment variables based on what
      # is available within payload
      #
      # @param payload [Hash]
      # @return [Hash]
      def common_environment_variables(payload)
        Smash.new.tap do |env|
          if(cfi = payload.get(:data, :code_fetcher, :info))
            cfi.each do |k,v|
              key = "CODE_FETCHER_#{k.to_s.upcase}"
              env[key] = v
            end
          end
        end
      end

    end

  end
end

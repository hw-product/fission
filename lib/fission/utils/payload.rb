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
        {
          :job => job,
          :message_id => Celluloid.uuid,
          :data => payload,
          :complete => []
        ).to_smash
      end

      # Extract generic information from payload
      #
      # @param payload [Hash]
      # @param key [String, Symbol] format type
      # @param source [String, Symbol] source of data
      # @return [Hash]
      # @see Formatter
      def format_payload(payload, key, source=nil)
        begin
          source = payload[:source] unless source
          Formatter.format(key, source, payload)
        rescue => e
          debug "Aborting rescued exception -> #{e.class}: #{e}\n#{e.backtrace.join("\n")}"
          abort e
        end
      end

    end

  end
end

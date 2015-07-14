require 'fission'

module Fission
  module Utils
    # Provide helpers for publishing events
    module Events

      # Send event
      #
      # @param type [String, Symbol] event type
      # @param data [Smash] optional data
      # @return [NilClass]
      def event!(type, data=Smash.new)
        payload = new_payload(
          :event, :event => Smash.new(
            :type => type,
            :stamp => Time.now.to_f,
            :data => data
          )
        )
        info "Sending event data - type: #{type} ID: #{payload[:message_id]}"
        debug "Sending event data - type: #{type} ID: #{payload[:message_id]} data: #{data.inspect}"
        eventers_for(type).each do |endpoint|
          debug "Sending event ID #{payload[:message_id]} to #{endpoint}"
          transmit(endpoint, payload)
        end
      end

      # Find sources registered to receive events of given type
      #
      # @param type [String, Symbol] event type
      # @return [Array<String,Symbol>] source names
      def eventers_for(type)
        app_config.fetch(:eventers, Smash.new).map do |m_type, e_srcs|
          if(File.fnmatch(m_type, type.to_s))
            e_srcs
          end
        end.flatten.compact.map(&:to_sym).uniq
      end

    end
  end
end

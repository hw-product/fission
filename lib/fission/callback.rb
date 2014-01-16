require 'carnivore/callback'
require 'fission/utils'
require 'fission/utils/notification_data'

module Fission
  class Callback < Carnivore::Callback

    include Fission::Utils::Transmission
    include Fission::Utils::MessageUnpack
    include Fission::Utils::Payload
    include Fission::Utils::NotificationData

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
    end

    # payload:: Hash payload
    # message:: Carnivore::Message instance
    # Send payload to error handler
    def failed(payload, message, reason='No message provided')
      payload[:error] ||= {}
      payload[:error][:callback] = name
      payload[:error][:reason] = reason
      endpoint = Carnivore::Config.get(:fission, :handlers, :error) ||
        Carnivore::Config.get(:fission, :handlers, :complete)
      if(endpoint)
        Celluloid::Actor[endpoint.to_sym].transmit(payload)
      else
        error "Payload of #{message} resulted in error state. No handler defined: #{payload.inspect}"
      end
    end

    # job:: name of job/component to check
    # payload:: Payload
    # Check if given job has been completed
    def completed?(job, payload)
      payload.map do |item|
        item.downcase.gsub(':', '_')
      end.include?(job.to_s.downcase.gsub(':', '_'))
    end

    # thing:: String or symbol of feature
    # Returns true if `thing` is enabled
    def enabled?(thing)
      !config_disabled(thing) && (config_enabled(thing) || constant_enabled(thing))
    end

    # thing:: String or symbol of feature
    # Returns true if `thing` is disabled
    def disabled?(thing)
      !enabled?(thing)
    end

    # thing:: String or symbol of feature
    # Returns true if `thing` is enabled in configuration
    def config_enabled(thing)
      check = thing.to_s
      to_check = [Carnivore::Config.get(:fission, :core, :enable)].flatten.compact
      to_check.include?(check)
    end

    # thing:: String or symbol of feature
    # Returns true if `thing` is disabled in configuration
    def config_disabled(thing)
      check = thing.to_s
      to_check = [Carnivore::Config.get(:fission, :core, :disable)].flatten.compact
      to_check.include?(check)
    end

    # thing:: String or symbol to check if constant is defined
    # Returns true if `thing` is a defined constant either at the top
    # level or within `Fission`
    # TODO: I didn't feel like implementing it now, but add support to
    # walk namespaces through constant list (i think i have this in a
    # mod_spox util)
    def constant_enabled(thing)
      Fission.constants.map do |const|
        const.to_s.downcase.to_sym
      end.include?(thing.to_s.downcase.to_sym)
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
        debug "#{e.class}: #{e}\n#{e.backtrace.join("\n")}"
        failed(payload, message, e.message)
      end
    end

  end
end

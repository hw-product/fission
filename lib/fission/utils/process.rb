require 'celluloid'
require 'shellwords'
require 'fileutils'
require 'tempfile'

module Fission
  module Utils
    class Process

      BLACKLISTED_ENV = ['GIT_DIR']

      include Celluloid

      # Creates new Process actor
      def initialize
        require 'childprocess'
        @registry = {}
        @locker = {}
        @base_env = ENV.to_hash
        @lock_wait = Celluloid::Condition.new
        @max_processes = Carnivore::Config.get(:fission, :utils, :process_manger, :max_processes) || 5
        @storage_directory = Carnivore::Config.get(:fission, :utils, :process_manager, :storage) ||
          '/tmp/fission/process_manager'
        FileUtils.mkdir_p(@storage_directory)

        every((Carnivore::Config.get(:fission, :utils, :process_manager, :poll) || 2.0).to_f){ check_running_procs }
        # configurable (also conditional - start stop based on active
        # non-notified processes in registry)
      end

      # identifier:: ID to reference the process
      # command:: Splat of additional arguments
      #   - String/Array argument -> used for command
      #   - Hash argument -> Merged into registry with `:process`
      #     - Provide :source for completion notification
      #     - Provide :payload for notification to be merged into payload
      #     - Provide :pending => {:interval => n_seconds, :source => dest, :reference => UUID}
      # Registers provided command. Yields process to block if
      # provided
      # Returns - boolean or abortions
      def process(identifier, *command)
        opts = command.detect{|i| i.is_a?(Hash)} || {}
        command.delete(opts)
        if(command.empty?)
          if(@registry.has_key?(identifier))
            p_lock = lock(identifier, false)
            if(p_lock)
              yield p_lock[:process]
              unlock(p_lock)
              true
            else
              abort Locked.new("Requested process is currently locked (#{identifier})")
            end
          else
            abort KeyError.new("Provided identifer is not currently registered (#{identifier})")
          end
        else
          if(@registry.has_key?(identifier))
            abort KeyError.new("Provided identifier already in use (#{identifier.inspect})")
          else
            check_process_limit!
            if(command.size == 1)
              command = Shellwords.shellsplit(command.first)
            end
            _proc = clean_env!{ ChildProcess.build(*command) }
            scrub_env(_proc.environment)
            @registry = @registry.dup.merge(
              identifier => opts.merge(
                :process => _proc,
                :command => command.join(' '),
                :start_time => Time.now.to_i
              )
            )
            if(block_given?)
              p_lock = lock(identifier)
              clean_env!{ yield p_lock[:process] }
              unlock(p_lock)
              true
            end
            if(opts[:pending])
              start_pending_notifier(
                identifier, opts[:pending][:source], opts[:pending][:interval]
              )
            end
          end
        end
        true
      end

      def generate_process_status(identifier, registry_entry)
        Smash.new(
          :process_manager => {
            :state => {
              :running => registry_entry[:process].alive?,
              :failed => registry_entry[:process].crashed? rescue false,
              :process_identifier => identifier,
              :reference_identifier => registry_entry[:reference],
              :elapsed_time => Time.now.to_i - registry_entry[:start_time]
            }
          }
        )
      end

      def start_pending_notifier(identifier, source, interval)
        timer = every(interval) do
          p_lock = lock(identifier)
          payload = Fission::Utils.new_payload(source,
            generate_process_status(identifier, p_lock[:registry_entry])
          )
          Fission::Utils.transmit(source, payload)
        end
        @registry[identifier][:pending_notifier] = timer
      end

      # identifier:: ID reference to process
      # Stops process if alive and unregisters it
      def delete(identifier)
        if(@registry[identifier][:process])
          locked = lock(identifier, false)
          if(locked)
            if(_proc = @registry[identifier][:process])
              if(_proc.alive?)
                _proc.stop
              end
            end
            if(_timer = @registry[identifier][:pending_notifier])
              _timer.cancel
            end
            [@registry, @locker].each{|hsh| hsh.delete(identifier) }
            true
          else
            abort StandardError.new("Failed to lock process (ID: #{identifier})")
          end
        else
          abort KeyError.new("Identifier provided is not registered (#{identifier.inspect})")
        end
      end

      # identifer:: ID reference to process
      # wait:: Wait until lock is obtained
      # Lock the process for exclusive usage
      def lock(identifier, wait=true)
        if(@registry[identifier])
          if(@registry[identifier][:process])
            if(locked?(identifier))
              if(wait)
                unlocked = nil
                waited = 0.0
                if(wait.is_a?(Numeric))
                  after(wait){ @lock_wait.signal(:__timeout) }
                end
                until(unlocked == identifier)
                  started = Time.now
                  unlocked = @lock_wait.wait
                  waited += (Time.now - started).to_f
                  return nil if unlocked == :__timeout
                end
                if(wait.is_a?(Numeric))
                  lock(identifier, wait - waited)
                else
                  lock(identifier, wait)
                end
              else
                nil
              end
            else
              @locker[identifier] = Celluloid.uuid
              {
                :registry_entry => @registry[identifier],
                :process => @registry[identifier][:process],
                :lock_id => @locker[identifier]
              }
            end
          end
        else
          abort KeyError.new("Requested process not found (identifier: #{identifier})")
        end
      end

      # process_or_ident:: Process instance or identifier
      # Unlock the process
      def unlock(lock_id)
        if(lock_id.is_a?(Hash))
          lock_id = lock_id[:lock_id]
        end
        key = @locker.key(lock_id)
        if(key)
          @locker.delete(key)
          @lock_wait.signal(key)
          true
        else
          abort KeyError.new("Provided lock id is not in use (#{lock_id})")
        end
      end

      # identifier:: ID reference to process
      # Return if process is currently locked
      def locked?(identifier)
        !!@locker[identifier]
      end

      # Raises `Error::ThresholdExceeded` if max process limit has
      # been met or exceeded
      def check_process_limit!
        if(@max_processes)
          not_complete = @registry.values.find_all do |_proc|
            c_proc = _proc[:process]
            begin
              !c_proc.exited?
            rescue ChildProcess::Error => e
              e.message == 'process not started'
            end
          end
          if(not_complete.size >= @max_processes)
            abort Error::ThresholdExceeded.new("Max process threshold reached (#{@max_processes} processes)")
          end
        end
      end

      # Create temporary IO for logging and return IO instance
      def create_io_tmp(*args)
        path = File.join(@storage_directory, args.join('-'))
        FileUtils.mkdir_p(File.dirname(path))
        t_file = Tempfile.new(path)
        t_file.sync
        t_file
      end

      private

      # Lock the identifier
      def lock_wrapped(identifier)
        lock(identifer)
      end

      # Checks currently registered processes for completion and sends
      # notifications if done
      def check_running_procs
        @registry.each do |identifier, _proc|
          if(!locked?(identifier) && !_proc[:notified] && _proc[:source] && !_proc[:process].alive?)
            payload = _proc[:payload] || {}
            payload[:data] ||= {}
            payload[:data].merge!(
              :process_notification => identifier
            ).merge!(generate_process_status(identifier, @registry[identifier]))
            _proc[:source].transmit(payload, nil)
            _proc[:notified] = true
            delete(identifier)
          end
        end
      end

      # process:: ChildProcess instance
      # Remove environment variables that are known should _NOT_ be set
      def clean_env!
        ENV.replace(@base_env.dup)
        scrub_env(ENV)
        if(defined?(Bundler))
          Bundler.with_clean_env{ yield }
        else
          yield
        end
      end

      # env:: Hash type thing
      # Scrubs configured keys from hash
      def scrub_env(env)
        [
          BLACKLISTED_ENV,
          Carnivore::Config.get(
            :fission, :utils, :process_manager, :blacklisted_env
          )
        ].flatten.compact.each do |key|
          env.delete(key)
        end
      end

    end
  end
end

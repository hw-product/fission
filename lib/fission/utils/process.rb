require 'celluloid'

module Fission
  module Utils
    class Process

      include Celluloid

      def initialize
        require 'childprocess'
        @registry = {}
        @locker = {}
        @lock_wait = Celluloid::Condition.new
        @max_processes = Carnivore::Config.get(:fission, :utils, :max_processes)
        every(5.0){ check_running_procs }
      end

      # identifier:: ID to reference the process
      # source:: `Carnivore::Source` to report completion
      # command:: Array - command to run
      # Registers provided command. Yields process to block if
      # provided
      # Returns - true
      def process(identifier, source, *command)
        if(@registry.has_key?(identifier) && command)
          abort KeyError.new("Provided identifier already in use (#{identifier.inspect})")
        end
        check_process_limit!
        _proc = ChildProcess.build(*(Array(command).flatten.compact))
        @registry[identifier] = {:process => _proc, :source => source}
        if(block_given?)
          yield @registry[identifier][:process]
        else
          true
        end
      end

      # identifier:: ID reference to process
      # Stops process if alive and unregisters it
      def delete(identifier)
        if(@registry[identifier][:process])
          locked = lock(identifier, false)
          if(locked)
            _proc = @registry[identifier][:process]
            if(_proc)
              if(_proc.alive?)
                _proc.stop
              end
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
              :process => @registry[identifier][:process],
              :lock_id => @locker[identifier]
            }
          end
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

      private

      # Checks currently registered processes for completion and sends
      # notifications if done
      def check_running_procs
        @registry.each do |identifier, _proc|
          if(!locked?(identifier) && !_proc[:notified] && _proc[:source] && !_proc[:process].alive?)
            _proc[:source].transmit({:process_notification => identifier}, nil)
            _proc[:notified] = true
          end
        end
      end

    end
  end
end

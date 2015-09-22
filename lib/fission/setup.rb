module Fission

  class << self

    # Register class into fission registry
    #
    # @param args [Object] argument list
    # @return [Class] set class
    # @note first param is source name. last param is class to
    # register. other params are used for keying
    def register(*args)
      key = args[0, args.size - 1].join('.')
      registration.set(key, registration.fetch(key, []).push(args.last).uniq)
    end

    # @return [Hash] registration
    def registration
      @registration ||= Smash.new
    end

    # Load all callbacks into defined sources
    def setup!
      Fission.registration.each do |key, klasses|
        klasses.each do |klass|
          args = [:fission, :workers, *key.split('.')]
          num = nil
          until(args.empty? || num)
            num = Carnivore::Config.get(*args)
            unless(num.is_a?(Fixnum))
              num = nil
              args.pop
            end
          end
          klass.workers = num.is_a?(Fixnum) ? num : 0
          src_key = key.split('.').first
          src = Carnivore::Source.source(src_key)
          if(src)
            name = klass.to_s.split('::').last
            src.add_callback(name, klass)
          else
            Carnivore::Utils.warn "Workers defined for non-registered source: #{key}"
          end
        end
      end

      # Setup process manager if needed
      # if(Carnivore::Config.get(:fission, :utils, :process, :max_processes).to_i > 0)
      #   require 'fission/utils/process'
      #   if(Carnivore::Config.get(:fission, :utils, :process, :spawn))
      #     ChildProcess.posix_spawn = true
      #   end
      #   Utils::Process.supervise_as :process_manager
      # end
    end
  end
end

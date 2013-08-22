module Fission
  class Worker::DataStorage < Worker

    attr_reader :options

    def initialize(options = {})
      @options = options
      Actor[:transport].register :data_storage, current_actor

      info 'Data Storage router initialized'
      start_storage
    end

    def set(k,v)
      @storage[k] = v
    end

    def get(k)
      @storage[k]
    end

    def terminate
    end
    
    protected
    
    def start_storage
      info "Building storage for #{self.class.name}"
      storage_dir
      
      uses = options[:use]
      adapters = options[:adapter]

      debug(storage_uses_proxies: uses)
      debug(storage_adapters: adapters)

      @storage = Moneta.build do
        uses.each do |proxy, options|
          use proxy.to_sym, options
        end

        adapters.each do |adapter, options|
          adapter adapter.to_sym, options
        end
      end

      debug(storage_created: @storage)
    end
    
    def storage_dir
      unless(@storage_dir)
        @storage_dir = options[:adapter].detect do |k,v|
          k == :File && v.respond_to?(:key?) && v.key?(:dir)
        end.last[:dir]
        if(@storage_dir && !File.directory?(@storage_dir))
          info self.class.name, "Creating storage directory #{@storage_dir}"
          FileUtils.mkdir_p @storage_dir
        end
      end
      @storage_dir
    end

  end
end

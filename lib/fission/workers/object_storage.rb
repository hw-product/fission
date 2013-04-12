module Fission
  class Worker::ObjectStorage < Worker

    attr_reader :cache, :options

    # exclusive :maybe_create_cache_dir

    def cache_dir
      @cache_dir ||= options[:adapter].detect do |k,v|
        k == :File &&
          v.respond_to?(:key?) &&
          v.key?(:dir)
      end.last[:dir]
    end

    def maybe_create_cache_dir
      unless File.exists?(cache_dir) && File.directory?(cache_dir)
        info "Creating cache dir #{cache_dir}"
        ::FileUtils.mkdir_p cache_dir
      end
    end

    def initialize options = {}
      @options = options
      Actor[:transport].register :object_storage, current_actor

      info 'Object Storage router initialized: caches flushed'

      maybe_create_cache_dir
      start_cache
    end

    def cache_payload_to_disk message
      debug(payload_message_received: message)
      @cache.store(Celluloid::UUID.generate, Marshal.dump(message))
    end

    def start_cache
      info "Building Moneta cache"

      uses = options[:use]
      adapters = options[:adapter]

      debug(cache_uses_proxies: uses)
      debug(cache_adapters: adapters)

      @cache = Moneta.build do
        # Ah use are stink fullas bey
        uses.each do |proxy, options|
          use proxy.to_sym, options
        end

        adapters.each do |adapter, options|
          adapter adapter.to_sym, options
        end
      end

      debug(cache_created: @cache)
    end

    def terminate
      @cache.do_something_crazy
    end

  end
end

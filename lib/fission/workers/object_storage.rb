require 'fission/workers/data_storage'

module Fission
  class Worker::ObjectStorage < DataStorage

    def initialize(options = {})
      @options = options
      Actor[:transport].register :object_storage, current_actor
      info 'Object Storage router initialized: caches flushed'
      start_cache
    end

    def cache_payload_to_disk(*args)
      if(args.size == 1)
        key = Celluloid::UUID.generate
        value = args.first
      else
        key, value = *args
      end
      set(k, v)
    end

    def terminate
    end

  end
end

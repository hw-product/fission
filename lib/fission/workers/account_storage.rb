require 'fission/workers/data_storage'

module Fission
  class Worker::AccountStorage < DataStorage

    def initialize(options = {})
      @options = options
      Actor[:transport].register :account_storage, current_actor
      start_cache
    end

    def store(account)
      data = get(account)
      data ||= {:jobs => [], :status => {}}
      yield data
      set(account, data)
    end
    
    def terminate
    end

  end
end

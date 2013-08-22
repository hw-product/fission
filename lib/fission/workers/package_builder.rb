module Fission
  class Worker::PackageBuilder < Worker
    
    def initialize
      info 'Package Builder initialized'
      Actor[:transport].register :package_builder, current_actor
    end

    def route_package_payload(message)
      debug(route_package_payload: message)
      message[:uuid] = Celluloid::UUID.generate
      debug(route_package_payload: "UUID Generated: #{message[:uuid]}")
      Actor[:transport][:account_storage].store!(message[:fission][:account]) do
        data[:jobs] << message
        data[:status][message[:uuid]] = {:state => :pending}
      end
      unless(message[:repository_private])
        info(route_package_payload: 'Sending repository clone request')
        Actor[:transport][:repository_fetcher].clone_repository!(message)
      else
        error(route_package_payload: 'Private repository clone not implemented')
      end
    end
    
    def clone_complete(message)
      debug(clone_complete: message)
      Actor[:transport][:container_router].package_from_repository!(message)
    end

    def terminate
    end

  end
end

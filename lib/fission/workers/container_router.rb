module Fission
  class Worker::ContainerRouter < Worker

    def initialize
      info 'Container Router initialized'
      Actor[:transport].register :container_router, current_actor
    end

    def package_from_repository repository_identifier
      debug(container_package_build_from_repository: "Starting Container")
    end

    def terminate
    end

  end
end

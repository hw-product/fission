module Fission
  class Worker::PackageBuilder < Worker

    def initialize
      info 'Package Builder initialized'
      Actor[:transport].register :package_builder, current_actor
    end

    def terminate
    end

  end
end

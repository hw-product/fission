module Fission
  class Worker::TestKitchen < Worker

    def initialize
      info 'Test Kitchen initialized'
      Actor[:transport].register :test_kitchen, current_actor
    end

    def test_from_repository repository_identifier
      puts "KITCHEN DOCKER RUN"
    end

    def terminate
    end

  end
end

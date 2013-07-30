module Fission
  class Worker::TestKitchen < Worker

    include Kitchen::ShellOut

    def initialize
      info 'Test Kitchen initialized'
      Actor[:transport].register :test_kitchen, current_actor
    end

    def test_from_repository repository_identifier
      run_command("echo 'foobarbaz'")
    end

    def terminate
    end

  end
end

module Fission
  class Worker::TestRunner < Worker

    def initialize
      info 'Test Runner initialized'
      Actor[:transport].register :test_runner, current_actor
    end

    def route_test_payload payload
      debug(route_test_payload: payload)
      repo_url = payload[:repository_url]
      repo_name = payload[:repository_name]
      owner_name = payload[:repository_owner_name]
      target_commit = payload[:target_commit]
      repository_is_private = payload[:repository_private] == 1
      Actor[:transport][:repository_fetcher].clone_repository(
        repo_url,
        owner_name,
        repo_name,
        target_commit,
      ) unless repository_is_private
    end

    def clone_complete repository_identifier
      debug(clone_complete: repository_identifier)
      Actor[:transport][:test_kitchen].test_from_repository(
        repository_identifier
      )
    end

    def terminate
    end

  end
end

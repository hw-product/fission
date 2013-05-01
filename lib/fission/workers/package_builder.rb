module Fission
  class Worker::PackageBuilder < Worker

    def initialize
      info 'Package Builder initialized'
      Actor[:transport].register :package_builder, current_actor
    end

    def route_package_payload message
      debug(payload_message_received: message)
      repo_url = message[:repository_url]
      repo_name = message[:repository_name]
      owner_name = message[:repository_owner_name]
      target_commit = message[:target_commit]
      repository_is_private = message[:repository_private] == 1
      key = [owner_name, repo_name].join('/')

      Actor[:transport][:repository_fetcher].clone_repository(
        repo_url,
        owner_name,
        repo_name,
        target_commit,
        ) unless repository_is_private
      # Actor[:transport][:object_storage].cache_payload_to_disk(key, message)
    end

    def clone_complete repository_identifier
      debug(package_builder_clone_completed: repository_identifier)
      Actor[:transport][:container_router].package_from_repository(
        repository_identifier
      )
    end

    def terminate
    end

  end
end

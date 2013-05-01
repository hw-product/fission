module Fission
  class Worker::RepositoryFetcher < Worker

    attr_reader :options, :repository

    def initialize options = {}
      @options = options
      Actor[:transport].register :repository_fetcher, current_actor
      info 'RepositoryFetcher initialized'
    end

    def change_protocol_to_git url
      uri = URI(url)
      uri.scheme = 'git'
      uri.to_s
    end

    def clone_repository repo_url, owner_name, repo_name, ref
      git_repo_url = change_protocol_to_git repo_url
      repository_identifier = "#{owner_name}/#{repo_name}@#{ref}"
      working_directory = File.join(
        options[:working_dir],
        repository_identifier
      )
      unless File.directory?(working_directory)
        debug(export_start: "starting export to #{working_directory}")

        repo = Git.clone(git_repo_url, working_directory, depth: 1)
        repo.checkout(ref)

        create_tar_from_repository working_directory

        debug(export_complete: 'export complete')

        Actor[:transport][:package_builder].clone_complete(
          repository_identifier
        )
      end
    end

    def create_tar_from_repository working_directory
      tar_path_name = File.join(
        options[:working_dir],
        Celluloid::UUID.generate + ".tgz"
      )
      args = %w{tar -cvzf}
      args << tar_path_name
      args << '.'
      debug(tar_args: args)
    end

    def terminate
    end

  end
end

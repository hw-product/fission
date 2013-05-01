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
        Dir.chdir(repo.dir.to_s) { FileUtils.rm_r '.git' }

        tar_file = create_tar_from_repository working_directory

        debug(export_complete: 'export complete')

        stage_tar_to_object_storage(
          repository_identifier,
          tar_file
        )

        Actor[:transport][:package_builder].clone_complete(
          repository_identifier
        )
      end
    end

    def stage_tar_to_object_storage repository_identifier, tar_file
      file = File.open(tar_file, 'r')
      stat = file.stat
      size = stat.size

      debug(stage_tar_to_object_storage: "sending #{tar_file.path}")
      debug(tar_file_size: size)

      Actor[:transport][:object_storage].cache_payload_to_disk(
        repository_identifier,
        file.read
      )

      debug(stage_tar_to_object_storage: 'complete')
    end

    def create_tar_from_repository working_directory
      tar_path_name = File.join(
        options[:working_dir],
        Celluloid::UUID.generate + ".tgz"
      )

      file = File.open(tar_path_name, 'wb')
      tgz = Zlib::GzipWriter.new(file)
      Archive::Tar::Minitar.pack('.', tgz)

      debug(tar_created: file.inspect)
      debug(tar_file_stat: File.stat(file))

      file
    end

    def terminate
    end

  end
end

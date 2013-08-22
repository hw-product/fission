module Fission
  class Worker::RepositoryFetcher < Worker

    include Archive::Tar

    attr_reader :options, :repository

    def initialize(options = {})
      @options = options
      Actor[:transport].register :repository_fetcher, current_actor
      info 'RepositoryFetcher initialized'
    end

    def change_protocol_to_git(url)
      uri = URI(url)
      uri.scheme = 'git'
      uri.to_s
    end

    def clone_repository(message)
      git_repo_url = change_protocol_to_git message[:repository_url]
      repository_identifier = "#{message[:repository_owner_name]}/#{message[:repository_name]}@#{message[:reference]}"
      working_directory = File.join(options[:working_dir], repository_identifier)

      unless(File.directory?(working_directory))
        debug(export_start: "starting export to #{working_directory}")

        repo = Git.clone(git_repo_url, working_directory, depth: 1)
        repo.checkout(message[:reference])
        Dir.chdir(repo.dir.to_s) { FileUtils.rm_rf '.git' }

        stage_tar(
          repository_identifier,
          repo.dir.to_s
        )

        debug(export_complete: 'export complete')

        message[:repository_identifier] = repository_identifier
        Actor[:transport][:package_builder].clone_complete(message)
      end
    end

    def stage_tar(repository_identifier, working_directory)

      raw_string = StringIO.new("rw")
      tar = Minitar::Output.new(raw_string)

      Dir.chdir(working_directory) do
        Find.find('.') do |entry|
          Minitar.pack_file(entry, tar)
        end
      end

      debug(stage_tar: "sending to object_storage key #{repository_identifier}")

      raw_string.rewind

      Actor[:transport][:object_storage].set(repository_identifier, raw_string.read)

      debug(stage_tar: 'complete')
    ensure
      tar.close
    end

    def terminate
    end

  end
end

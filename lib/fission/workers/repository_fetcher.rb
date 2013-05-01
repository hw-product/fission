module Fission
  class Worker::RepositoryFetcher < Worker

    include Archive::Tar

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

        stage_tar(
          repository_identifier,
          repo.dir.to_s
        )

        debug(export_complete: 'export complete')

        Actor[:transport][:package_builder].clone_complete(
          repository_identifier
        )
      end
    end

    def stage_tar repository_identifier, working_directory

      raw_string = StringIO.new("rw")
      sgz = Zlib::GzipWriter.new(raw_string)
      tgz = Minitar::Output.new(sgz)

      Dir.chdir(working_directory) do
        Find.find('.') do |entry|
          Minitar.pack_file(entry, tgz)
        end
      end

      debug(stage_tar: "sending to object_storage key #{repository_identifier}")

      raw_string.rewind

      Actor[:transport][:object_storage].cache_payload_to_disk(
        repository_identifier,
        raw_string.read
      )

      debug(stage_tar: 'complete')
    ensure
      tgz.close
    end

    def terminate
    end

  end
end

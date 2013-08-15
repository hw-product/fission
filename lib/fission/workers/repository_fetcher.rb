module Fission
  class Worker::RepositoryFetcher < Worker

    include Archive::Tar

    attr_reader :options, :repository

    def initialize options = {}
      @options = options
      Actor[:transport].register :repository_fetcher, current_actor
      info 'RepositoryFetcher initialized'
    end

    def clone_repository repo_url, owner_name, repo_name, ref, sha
      repository_identifier = "#{owner_name}/#{repo_name}@#{sha}"
      working_directory = File.join(
        options[:working_dir],
        repository_identifier
      )

      unless File.directory?(working_directory)
        debug(export_start: "starting export to #{working_directory}")

        Fission::Git.clone repo_url, working_directory, depth: 1, branch: ref.gsub(%r(^refs/heads/), '')
        Fission::Git.checkout working_directory, sha
        FileUtils.rm_r File.join(working_directory, '.git')

        stage_tar(
          repository_identifier,
          working_directory
        )

        debug(export_complete: 'export complete')

        Actor[:transport][:test_runner].clone_complete(
          repository_identifier
        )
      end
    end

    def stage_tar repository_identifier, working_directory

      raw_string = StringIO.new("rw")
      tar = Minitar::Output.new(raw_string)

      Find.find(working_directory) do |entry|
        Minitar.pack_file(entry, tar)
      end

      debug(stage_tar: "sending to object_storage key #{repository_identifier}")

      raw_string.rewind

      Actor[:transport][:object_storage].cache_payload_to_disk(
        repository_identifier,
        raw_string.read
      )

      debug(stage_tar: 'complete')
    ensure
      tar.close
    end

    def terminate
    end

  end
end

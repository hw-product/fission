require 'fission/packomatic'
require 'childprocess'
require 'tempfile'
require 'fileutils'

module Fission
  class Worker::ContainerRouter < Worker

    include Archive::Tar

    attr_reader :repository_path
    attr_reader :dna_path
    attr_reader :processes
    
    def initialize(config)
      info 'Container Router initialized'
      
      ChildProcess.posix_spawn = true

      @repository_path = File.join(config[:working_dir], 'repositories')
      @dna_path = File.join(config[:working_dir], 'dna')
      @processes = {}
      
      [repository_path, dna_path].each do |dir|
        FileUtils.mkdir_p(dir)
      end
      Actor[:transport].register :container_router, current_actor
    end

    def package_from_repository(message)
      debug(package_from_repository: 'Starting package build from repository')
      unpack_store_for_bind(message)
      dna_path = generate_dna(message)
      build_package!(dna_path, message)
    end

    def generate_dna(message)
      configuration = load_packomatic(message)
      dna = {}
      dna[:run_list] = ['recipe[fission]']
      dna[:fission] = configuration
      dna[:fission][:source] = message[:repository_directory]
      dna[:fission][:_message] = message
      dna[:fission][:internal_endpoint] = Fission::Config[:internal_endpoint]
      dna_file = File.join(dna_path, message[:uuid], 'fission.dna')
      FileUtils.mkdir_p(File.dirname(dna_file))
      File.open(dna_file, 'w') do |file|
        file.puts dna.inspect
      end
      dna_file
    end

    def build_package(dna_path, message)
      process = ChildProcess.build(
        'sudo', 'chef-solo', '--config', chef_config_path,
        '-j', dna_path, '--force-logger', '--logfile',
        File.join(File.dirname(dna_path), 'fission.log')
      )
      process.io.inherit!
      process.detach = true
      processes[message[:uuid]] = process
      process.start
      Actor[:transport][:account_storage].store!(message[:fission][:account]) do |data|
        data[:status][message[:uuid]][:location] = 'NODE_LOCATION'
        data[:status][message[:uuid]][:state] = :in_progress
      end
    end
    
    def load_packomatic
      path = File.join(message[:repository_directory], '.Packomatic')
      user_pack = Module.new.instance_eval(IO.read(path), path, 1)
      Packomatic.base._merge(user_pack)._dump
    end
    
    def unpack_store_for_bind(message)
      debug(unpack_store_for_bind: repository_identifier)
      debug(unpack_store_for_bind: message)
      message[:builder][:base_directory] = File.join(repository_path, message[:repository_owner], message[:repository_name])
      message[:builder][:repository_directory] = File.join(message[:builder][:base_directory], message[:repository_identifier])
      repo_pack = Actor[:transport][:object_storage].get(message[:repository_identifier])
      stringified = StringIO.new(repo_pack)
      Minitar::Input.open(stringified) do |reader|
        reader.each do |entry|
          reader.extract_entry(dest_dir, entry)
        end
      end
    end
    
    def terminate
    end

  end
end

require 'fission'
require 'stringio'

module Fission
  module Utils

    module RemoteProcessing

      # @return [Fission::Utils::RemoteProcess]
      def remote_process(args={})
        args = args.to_smash
        RemoteProcess.new(
          :api => args.fetch(:api, fission_config.get(:remote_process, :api)),
          :image => args.fetch(:image, 'fission-default'),
          :flavor => args.fetch(:flavor, 'default')
        )
      end

    end

    # Provide remote process support
    class RemoteProcess

      # Result of execute
      Result = Struct.new('RemoteProcessResult', :exit_code, :output) do

        def success?
          exit_code == 0
        end

      end

      include Zoidberg::SoftShell

      # @return [Miasma::Models::Compute] remote api
      attr_reader :api
      # @return [Miasma::Models::Compute::Server] remote instance
      attr_reader :server

      # Create remote endpoint for running commands
      #
      # @param opts [Hash] setup information
      # @return [self]
      def initialize(opts={})
        opts = opts.to_smash
        api = Miasma.api(opts[:api].merge(:type => :compute))
        @server = api.servers.build(
          :name => "fission-#{Carnivore.uuid}",
          :image_id => opts[:image],
          :flavor_id => opts[:flavor],
          :custom => Smash.new(
            :ephemeral => true
          )
        )
        @server.save
      end

      # Execute command on remote system
      #
      # @param cmd [String] command
      # @param opts [Hash]
      # @option opts [Hash] :environment
      # @option opts [IO] :stream
      # @return [
      def exec(cmd, opts={})
        output = opts.fetch(:stream, StringIO.new(''))
        code = server.api.server_execute(server, cmd,
          :stream => output,
          :return_exit_code => true
        )
        output.rewind if output.respond_to?(:rewind)
        Result.new(code, output)
      end

      # Same as #exec but raises on failure
      def exec!(cmd, opts={})
        result = exec(cmd, opts)
        unless(result.success?)
          error = Fission::Error::RemoteProcessFailed.new("Process execution failed (cmd: #{cmd})!")
          error.result = result
          raise error
        end
        result
      end

      # Fetch file from remote system
      #
      # @param path [String] path to remote file
      # @return [IO-ish]
      def get_file(path)
        server.api.server_get_file(server, path)
      end

      # Place file on remote system
      #
      # @param local_io [IO-ish] local file
      # @param remote_path [String] path to remote location
      # @param opts [Hash]
      # @return [TrueClass]
      def push_file(local_io, remote_path, opts={})
        server.api.server_put_file(server, local_io, remote_path, opts)
      end

      # Cleanup server instance
      def terminate
        Carnivore::Logger.debug "Sending server termination for #{server}"
        server.destroy
      end

    end
  end
end

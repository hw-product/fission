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

      # Default image when none provided
      DEFAULT_IMAGE = 'fission-default'

      # Simple wrapper to use a queue for storing output information
      # which can be pulled on demand
      class QueueStream < Queue
        alias_method :write, :push
      end

      # Result of execute
      Result = Struct.new('RemoteProcessResult', :exit_code, :output) do

        # @return [TrueClass, FalseClass]
        def success?
          exit_code == 0
        end

      end

      include Zoidberg::SoftShell

      # @return [Miasma::Models::Compute] remote api
      attr_reader :api
      # @return [Miasma::Models::Compute::Server] remote instance
      attr_reader :server

      class << self

        def build(opts={})
          args = Smash.new
          args[:base_image] = generate_target(opts.fetch(:target, {}))
          args[:dependencies] = generate_dependencies(opts[:dependencies])
          args[:repositories] = generate_repositories(opts.get(:setup, :repositories))
          args[:setup_commands] = generate_setup(opts.get(:setup, :commands))
          args[:image] = generate_image_name(args)
          create_or_start(opts.to_smash.merge(args))
        end

        def create_or_start(opts)
          api = Miasma.api(opts[:api].merge(:type => :compute))
          if(api.image_exists?(args[:image]))
            self.new(opts)
          else
            template_node = self.new(
              opts.merge(
                :image => opts[:base_image]
              )
            )
            configure_template_node(template_node, opts)
            api.image_create(template_node, opts[:image])
            template_node.destroy
            create_or_start(opts)
          end
        end

        def configure_template_node(node, opts)
          # copy cookbook pack
          # install chef
          # write dna.json
          # delete/cleanup
          # done
        end

        # Generate a unique name via builder hash
        #
        # @param opts [Hash]
        # @return [String]
        def generate_image_name(opts={})
          opts = opts.to_smash.dup
          base = opts.delete(:base_image)
          opts.all?{|o| o.nil? || o.empty?} ? base : opts.checksum
        end

        # Generate list of package dependencies
        #
        # @param opts [Hash]
        # @return [Array<String>]
        def generate_dependencies(opts={})
          case opts
          when Array
            opts
          when Hash
            opts.fetch(:build, [])
          else
            []
          end
        end

        # Generate base target image name
        #
        # @param opts [Hash]
        # @return [String]
        def generate_target(opts={})
          parts = [
            opts[:platform],
            opts[:version].to_s.tr('.', ''),
            opts[:arch]
          ]
          parts.delete_if{|i| i.nil? || i.blank? }
          target = parts.join('_')
          if(target.blank?)
            target = DEFAULT_IMAGE
          end
          target
        end

      end

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
            :ephemeral => opts.fetch(:ephemeral, true)
          )
        )
        @server.save
        unless(opts[:no_wait])
          Bogo::Retry::Linear.new(:wait_interval => 0.5, :max_attempts => 10) do
            wait_for_network!
          end
        end
      end

      # @return [TrueClass]
      def wait_for_network!
        exec!('ping -c 1 www.google.com')
      end

      # Execute command on remote system
      #
      # @param cmd [String] command
      # @param opts [Hash]
      # @option opts [Hash] :environment
      # @option opts [String] :cwd
      # @option opts [IO] :stream
      # @option opts [Integer] :timeout
      # @return [Result]
      def exec(cmd, opts={})
        output = opts.fetch(:stream, StringIO.new(''))
        if(opts[:cwd])
          wrap = StringIO.new("#!/bin/sh\ncd #{opts[:cwd]}\n#{cmd}")
          push_file(wrap, '/tmp/.remote_process_wrap')
          exec('chmod 755 /tmp/.remote_process_wrap')
          cmd = '/tmp/.remote_process_wrap'
        end
        code = server.api.server_execute(server, cmd,
          :stream => output,
          :return_exit_code => true,
          :timeout => opts.fetch(:timeout, 20),
          :environment => Smash.new(
            'HOME' => '/root',
            'USER' => 'root'
          ).merge(opts.fetch(:environment, {}))
        )
        if(output.respond_to?(:rewind) && (!output.respond_to?(:tty?) || !output.tty?))
          output.rewind
        end
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

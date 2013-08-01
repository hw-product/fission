require 'librarian'
require 'childprocess'

module Librarian
  module Source
    class Git
      class Repository

        class << self

          def clone! environment, path, repository_url
            path = Pathname.new(path)
            git = new environment, path
            git.clone! repository_url
            git
          end

        end

        def clone!(repository_url)
          ::Git.clone(repository_url, path)
        end

        private

        def run! args, options = {}
          env = {
            GIT_DIR: File.join(path, '.git'),
            GIT_WORK_TREE: path
          }

          command = [bin]
          command.concat(args)

          run_command_internal(command, env: env)
        end

        def run_command_internal cmd, options = {}
          stdout_r, stdout_w = IO.pipe
          stderr_r, stderr_w = IO.pipe

          process = ChildProcess.build(*cmd)

          process.io.stdout = stdout_w
          process.io.stderr = stderr_w

          if options[:env]
            options[:env].each do |k, v|
              process.environment[k.to_s] = v
            end
          end

          process.start
          process.wait

          stdout_w.close; stderr_w.close

          stdout = stdout_r.read
          stderr = stderr_r.read

          stdout_r.close; stderr_r.close

          if process.exit_code != 0
            raise StandardError, stderr
          end

          stdout
        ensure
          [stdout_r, stdout_w, stderr_r, stderr_w].each do |io|
            io.close unless io.closed?
          end
        end
      end
    end
  end
end

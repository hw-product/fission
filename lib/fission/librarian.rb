require 'librarian'
require 'childprocess'

module Librarian
  module Source
    class Git
      class Repository
        private

        def run_command_internal cmd, options = {}
          stdout_r, stdout_w = IO.pipe
          stderr_r, stderr_w = IO.pipe

          process = ChildProcess.build(*cmd)

          process.io.stdout = stdout_w
          process.io.stderr = stderr_w

          process.cwd = options[:chdir] if options[:chdir]
          process.environment = options[:env] if options[:env]

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

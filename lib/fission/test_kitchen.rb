require 'kitchen'
require 'childprocess'
require 'shellwords'

module Kitchen
  module ShellOut
    def run_command cmd, options = {}
      use_sudo = options[:use_sudo].nil? ? false : options[:use_sudo]
      quiet = options[:quiet]
      cmd = "sudo -E #{cmd}" if use_sudo
      subject = "[#{options[:log_subject] || "local"} command]"

      info("#{subject} BEGIN (#{display_cmd(cmd)})") unless quiet

      stdout_r, stdout_w = IO.pipe
      stderr_r, stderr_w = IO.pipe

      process = ChildProcess.build(*cmd.shellsplit)

      process.io.stdout = stdout_w
      process.io.stderr = stderr_w

      process.duplex = true if options[:input]

      process.start

      if options[:input]
        process.io.stdin.write options[:input]
        process.io.stdin.close
      end

      process.wait

      stdout_w.close; stderr_w.close

      stdout = stdout_r.read
      stderr = stderr_r.read

      stdout_r.close; stderr_r.close

      if process.exit_code != 0
        raise ShellCommandFailed, stderr
      end

      stdout
    rescue Exception => error
      error.extend(Kitchen::Error)
      raise error
    ensure
      [stdout_r, stdout_w, stderr_r, stderr_w].each do |io|
        io.close unless io.closed?
      end
    end
  end
end

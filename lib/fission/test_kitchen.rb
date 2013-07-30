require 'shellwords'
require 'kitchen'
require 'spoon'

module Kitchen
  module ShellOut
    def run_command(cmd, options = {})
      use_sudo = options[:use_sudo].nil? ? false : options[:use_sudo]
      quiet = options[:quiet]
      cmd = "sudo -E #{cmd}" if use_sudo
      subject = "[#{options[:log_subject] || "local"} command]"

      info("#{subject} BEGIN (#{display_cmd(cmd)})") unless quiet

      stdout_pipe, stderr_pipe = IO.pipe, IO.pipe

      file_actions = Spoon::FileActions.new

      file_actions.dup2(1, stdout_pipe.last.to_i)
      file_actions.dup2(2, stderr_pipe.last.to_i)

      spawn_attr = Spoon::SpawnAttributes.new

      args = cmd.shellsplit
      pid = Spoon.posix_spawn(args[0], file_actions, spawn_attr, args)

      _, status = Process.wait2(pid)

      if status.exitstatus != 0
        raise ShellCommandFailed
      end

      stdout_pipe.last.close
      stderr_pipe.last.close

      stdout = stdout_pipe.first.read
      stderr = stderr_pipe.first.read

      stdout + stderr
    rescue Exception => error
      error.extend(Kitchen::Error)
      raise
    ensure
      [stdout_pipe, stderr_pipe].each do |pipe|
        pipe.reverse.each do |io|
          io.close unless io.closed?
        end
      end
    end
  end
end

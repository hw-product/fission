module Fission
  module Command

    def safe_run cmd, options = {}
      use_sudo = options[:use_sudo].nil? ? false : options[:use_sudo]
      cmd = "sudo -E #{cmd}" if use_sudo

      stdout_r, stdout_w = IO.pipe
      stderr_r, stderr_w = IO.pipe

      process = ChildProcess.build *cmd.shellsplit

      process.io.stdout = stdout_w
      process.io.stderr = stderr_w

      if options[:env]
        options[:env].each do |k, v|
          process.environment[k.to_s] = v
        end
      end

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

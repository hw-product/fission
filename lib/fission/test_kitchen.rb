module Kitchen
  module ShellOut
    include Fission::Command

    def run_command cmd, options = {}
      subject = "[#{options[:log_subject] || "local"} command]"
      info "#{subject} BEGIN (#{display_cmd(cmd)})" unless quiet
      safe_run cmd, options
    rescue Exception => error
      error.extend Kitchen::Error
      raise error
    end
  end
end

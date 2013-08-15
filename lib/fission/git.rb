module Fission
  class Git
    class << self

      include Command

      def clone url, path, options = {}
        options = options.dup
        env = options.delete :env
        flags = git_flags options
        safe_run "git clone #{flags} #{url} #{path}", env: env
      end

      def checkout path, reference
        safe_run "git checkout #{reference}", env: git_env(path)
      end

      def git_flags options
        flags = []
        options.each do |k,v|
          flags << (v.is_a?(TrueClass) ? "--#{k}" : "--#{k} #{v}")
        end
        flags.join(' ')
      end

      def git_env path
        {
          GIT_DIR: File.join(path, '.git'),
          GIT_WORK_TREE: path
        }
      end
    end
  end
end


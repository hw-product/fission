module Librarian
  module Source
    class Git
      class Repository
        include Fission::Command

        def self.clone! environment, path, repository_url
          path = Pathname.new path
          git = new environment, path
          git.clone! repository_url
          git
        end

        def clone! repository_url
          Fission::Git.clone repository_url, path, quiet: true
        end

        private

        def git_env
          {
            GIT_DIR: File.join(path, '.git'),
            GIT_WORK_TREE: path
          }
        end

        def run! args, options = {}
          command = [bin]
          command.concat args
          safe_run command.join(' '), env: git_env
        end
      end
    end
  end
end

require 'fission'

module Fission
  class Formatter
    # Github data formatter
    class Github < Formatter

      # Mapping data for repository information
      REPOSITORY_MAPS = {
        :push => {
          :commit_sha => [:data, :github, :head_commit, :id],
          :name => [:data, :github, :repository, :name],
          :user_name => [:data, :github, :pusher, :name],
          :user_email => [:data, :github, :pusher, :email],
          :owner_name => [:data, :github, :repository, :owner, :name],
          :owner_email => [:data, :github, :repository, :owner, :email],
          :url => [:data, :github, :repository, :url],
          :ref => [:data, :github, :ref],
          :private => [:data, :github, :repository, :private],
          :tag => lambda{|data| data.get(:data, :github, :ref).to_s.split('/')[1] == 'tags' }
        },
        :create => {
          :commit_sha => lambda{|data|
            ref = data.get(:data, :github, :ref)
            info = github_client(data).tags(data.get(:data, :github, :repository, :full_name)).detect do |tag_details|
              tag_details[:name] == ref
            end
            if(info)
              info[:commit][:sha]
            end
          },
          :name => [:data, :github, :repository, :name],
          :user_name => [:data, :github, :sender, :login],
          :user_email => lambda{|data|
            user = github_client(data).user(data.get(:data, :github, :sender, :login))
            user[:email] if user
          },
          :owner_name => [:data, :github, :repository, :owner, :login],
          :owner_email => lambda{|data|
            org = github_client(data).org(data.get(:data, :github, :repository, :owner, :login))
            org[:email] if org
          },
          :url => [:data, :github, :repository, :clone_url],
          :ref => [:data, :github, :ref],
          :private => [:data, :github, :repository, :private],
          :tag => lambda{|data| data.get(:data, :github, :ref_type) == 'tag' }
        }
      }

      extend Fission::Utils::Github
      extend Fission::Utils::Inspector

      # Create new instance
      #
      # @param payload [Hash]
      # @param type [String, Symbol] type of data format
      def initialize(*args)
        super
        if(type == :default)
          if(event_type = data.get(:data, :github, :github_event))
            @type = event_type.to_sym
          else
            @type = :push
          end
        end
      end

      # Generate new data structure
      #
      # @param key [String, Symbol] what to translate
      # @return [Hash]
      def data_for(key)
        case key.to_sym
        when :repository
          data.get(:data, :format, :repository) || repository_extract
        else
          super
        end
      end

      # Build new data structure for repository
      #
      # @return [Hash]
      def repository_extract
        begin
          unless(REPOSITORY_MAPS[type])
            raise KeyError.new "Unknown repository mapping type received (#{type})"
          end
          repo_info = Smash.new.tap do |info|
            REPOSITORY_MAPS[type].each do |key, args|
              if(args.is_a?(Array))
                info[key] = data.get(*args)
              elsif(args.respond_to?(:call))
                info[key] = args.call(data)
              else
                raise TypeError.new "Expected type `Array` or `Proc` but got `#{args.class}`"
              end
            end
          end
          data.set(:data, :format, :repository, repo_info)
          repo_info
        rescue => e
          exception_log(e)
          raise Error::TranslationFailed.new(e.message)
        end
      end

    end
  end
end

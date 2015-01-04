require './fission_dependencies'
source 'https://rubygems.org'

gem 'sleepy_penguin'
gem 'carnivore-files', git: 'git@github.com:carnivore-rb/carnivore-files.git'
gem 'carnivore-http'
gem 'carnivore-actor'
gem 'jackal', git: 'git@github.com:carnivore-rb/jackal.git', branch: 'develop'

gem 'octokit'
gem 'elecksee', '~> 1.0.22'
gem 'pg'
gem 'reaper', git: 'git@github.com:heavywater/reaper.git'
gem 'pry'

gem 'minitest'

if(RUBY_PLATFORM == 'java')
  gem 'jruby_sandbox'
end

FissionDependencies::GEMS.each do |lib|
  local  = { path: "../#{lib}" }
  remote = { git: "git@github.com:heavywater/#{lib}.git", branch: 'develop' }
  opts   = (ENV['FISSION_LOCALS'] == 'true') ? local : remote

  gem lib, opts
end

gemspec

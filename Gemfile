require File.expand_path('fission_dependencies', File.dirname(__FILE__))
source 'https://rubygems.org'
gem 'miasma-local', :path => '/home/spox/Projects/chrisroberts/miasma-all/miasma-local'
gem 'sleepy_penguin'
gem 'carnivore-files', git: 'git@github.com:carnivore-rb/carnivore-files.git'
gem 'carnivore', :path => '/home/spox/Projects/chrisroberts/carnivore/carnivore'
gem 'jackal', :path => '/home/spox/Projects/chrisroberts/carnivore/jackal'
gem 'jackal-slack', :path => '/home/spox/Projects/chrisroberts/carnivore/jackal-slack'
gem 'jackal-assets', :path => '/home/spox/Projects/chrisroberts/carnivore/jackal-assets'
gem 'jackal-nellie', :path => '/home/spox/Projects/chrisroberts/carnivore/jackal-nellie'
gem 'jackal-code-fetcher', :path => '/home/spox/Projects/chrisroberts/carnivore/jackal-code-fetcher'
gem 'jackal-github-kit', :path => '/home/spox/Projects/chrisroberts/carnivore/jackal-github-kit'
gem 'jackal-github', :path => '/home/spox/Projects/chrisroberts/carnivore/jackal-github'

gem 'carnivore-http', :path => '/home/spox/Projects/chrisroberts/carnivore/carnivore-http'
gem 'carnivore-actor'

gem 'octokit'
gem 'elecksee', :path => '/home/spox/Projects/chrisroberts/elecksee'
gem 'pg'
gem 'reaper', git: 'git@github.com:heavywater/reaper.git'
gem 'pry'

gem 'minitest'

if(RUBY_PLATFORM == 'java')
  gem 'jruby_sandbox'
end

FissionDependencies::GEMS.each do |lib|
  local  = { path: "../#{lib}" }
  remote = { git: "git@github.com:hw-product/#{lib}.git", branch: 'develop' }
  opts   = ENV['FISSION_LOCALS'] == 'true' ? local : remote

  gem lib, opts
end

gemspec

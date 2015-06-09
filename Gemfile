require File.expand_path('fission_dependencies', File.dirname(__FILE__))
source 'https://rubygems.org'

gem 'sleepy_penguin'
gem 'carnivore-http'
gem 'carnivore-actor'
gem 'jackal', git: 'git@github.com:carnivore-rb/jackal.git', branch: 'develop'

gem 'octokit'
gem 'elecksee'
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

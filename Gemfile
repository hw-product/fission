source 'https://rubygems.org'

gem 'sleepy_penguin'
gem 'carnivore-files', git: 'git@github.com:carnivore-rb/carnivore-files.git'
gem 'carnivore-http'
gem 'carnivore-actor'
gem 'carnivore', git: 'git@github.com:carnivore-rb/carnivore.git', branch: 'develop'

gem 'octokit'
gem 'elecksee', '~> 1.0.20'
gem 'pg'
gem 'reaper', git: 'git@github.com:heavywater/reaper.git'
gem 'pry'

gem 'minitest'

if(RUBY_PLATFORM == 'java')
  gem 'jruby_sandbox'
end

%w(
  assets webhook code-fetcher data
  finalizers github-release nellie package-builder
  rest-api router validator mail repository-generator
  repository-publisher github-comment nellie-webhook
  woodchuck woodchuck-filter
).each do |fission_library|
  if(ENV['FISSION_LOCALS'] == 'true')
    gem "fission-#{fission_library}", path: "../fission-#{fission_library}"
  else
    gem "fission-#{fission_library}", git: "git@github.com:heavywater/fission-#{fission_library}.git", branch: 'develop'
  end
end

gemspec

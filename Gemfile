source 'https://rubygems.org'

gem 'carnivore', git: 'git@github.com:carnivore-rb/carnivore.git', branch: 'develop'
gem 'carnivore-http', git: 'git@github.com:carnivore-rb/carnivore-http.git', branch: 'develop'
gem 'carnivore-sqs', git: 'git@github.com:carnivore-rb/carnivore-sqs.git', branch: 'develop'
gem 'carnivore-actor', git: 'git@github.com:carnivore-rb/carnivore-actor.git', branch: 'develop'
gem 'octokit'
gem 'elecksee', '~> 1.0.20'
gem 'risky', git: 'git://github.com/chrisroberts/risky.git', branch: 'updates'

gem 'reaper', git: 'git@github.com:heavywater/reaper.git'

if(RUBY_PLATFORM == 'java')
  gem 'jruby_sandbox'
end

%w(
  app-jobs assets callbacks code-fetcher data
  finalizers github-release nellie package-builder
  rest-api router validator mail repository-generator
  repository-publisher
).each do |fission_library|
  if(ENV['FISSION_LOCALS'] == 'true')
    gem "fission-#{fission_library}", path: "../fission-#{fission_library}"
  else
    gem "fission-#{fission_library}", git: "git@github.com:heavywater/fission-#{fission_library}.git", branch: 'develop'
  end
end

gemspec

source 'https://rubygems.org'

gem 'carnivore', git: 'git@github.com:carnivore-rb/carnivore.git', branch: 'develop'
gem 'carnivore-http', git: 'git@github.com:carnivore-rb/carnivore-http.git', branch: 'develop'
gem 'carnivore-sqs', git: 'git@github.com:carnivore-rb/carnivore-sqs.git'
gem 'carnivore-actor', git: 'git@github.com:carnivore-rb/carnivore-actor.git', branch: 'develop'
gem 'elecksee', git: 'git://github.com/chrisroberts/elecksee.git', branch: 'develop'
gem 'risky', git: 'git://github.com/chrisroberts/risky.git', branch: 'updates'

%w(
  app-jobs assets callbacks code-fetcher data
  finalizers github-release nellie package-builder
  rest-api router validator
).each do |fission_library|
  if(ENV['FISSION_LOCALS'] == 'true')
    gem "fission-#{fission_library}", path: "../fission-#{fission_library}"
  else
    gem "fission-#{fission_library}", git: "git@github.com:heavywater/fission-#{fission_library}.git", branch: 'develop'
  end
end

gemspec

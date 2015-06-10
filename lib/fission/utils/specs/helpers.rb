# Bump up setup wait time
unless(ENV['CARNIVORE_SOURCE_SETUP'])
  ENV['CARNIVORE_SOURCE_SETUP'] = '0.5'
end

# Pass any fission specific wait settings down to jackal
ENV.each do |key, value|
  if(key.start_with?('FISSION_SOURCE_'))
    jackal_key = key.sub('FISSION_SOURCE', 'JACKAL_SOURCE')
    ENV[jackal_key] = value
  end
end

require 'jackal/utils/spec/helpers'

Jackal::Utils::Spec.system_runner = Fission::Runner

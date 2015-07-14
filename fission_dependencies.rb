# Separate these out of Gemfile so repos can be dynamically cloned
# Note: if you change this file, please update the following file:
#   https://github.com/hw-product/fission-vagrant-testing/blob/develop/bin/clone-repos
class FissionDependencies
  GEMS = %w(
    fission-assets
    fission-data
    fission-mail
    fission-nellie
    fission-package-builder
    fission-repository-generator
    fission-repository-publisher
    fission-rest-api
    fission-router
    fission-validator
    fission-woodchuck
    fission-woodchuck-filter
  )
end

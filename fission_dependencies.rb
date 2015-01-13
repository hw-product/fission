# Separate these out of Gemfile so repos can be dynamically cloned
# Note: if you change this file, please update the following file:
#   https://github.com/hw-product/fission-vagrant-testing/blob/develop/bin/clone-repos
class FissionDependencies
  GEMS = %w(
    fission-assets
    fission-code-fetcher
    fission-data
    fission-finalizers
    fission-github-comment
    fission-github-release
    fission-mail
    fission-nellie
    fission-nellie-webhook
    fission-package-builder
    fission-repository-generator
    fission-repository-publisher
    fission-rest-api
    fission-router
    fission-validator
    fission-webhook
    fission-woodchuck
    fission-woodchuck-filter
  )
end

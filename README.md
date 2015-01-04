# Fission

Fission provides a set of base utilities and subclasses to drive the platform.  It allows one to specify (via a json configuration file) a pipeline of services to apply to one's infrastructure.  Pipeline components may have input and output specifiers in order to route the flow data between components.

## About

## Getting Started

## Usage examples

```
$ bundle update
$ bundle exec fission -c examples/http.json
```

Send it something:

```
$ curl --data @examples/payloads/github.json http://localhost:9876/github-commit/
```

## Local Development
See: https://github.com/hw-product/fission/blob/develop/HACKING.md

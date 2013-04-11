require 'blockenspiel'
require 'singleton'

module Fission
  class ApiBuilder
    include Blockenspiel::DSL
    include Singleton

    def initialize
      @str_endpoints = {}
      @regexp_endpoints = {}
    end

    [:get, :put, :post, :delete, :head, :options, :trace].each do |name|
      define_method(name) do |regexp_or_string, &block|
        endpoint(name, regexp_or_string, &block)
      end
    end

    def endpoint(request_type, regexp_or_string, &block)
      request_type = request_type.to_sym
      case regexp_or_string
      when String
        @str_endpoints[request_type] ||= {}
        @str_endpoints[request_type][regexp_or_string] = block
      when Regexp
        @regexp_endpoints[request_type] ||= {}
        @regexp_endpoints[request_type][regexp_or_string] = block
      else
        raise 'Unsupported endpoint defininition'
      end
    end

    dsl_methods false

    def endpoints
      [@str_endpoints, @regexp_endpoints]
    end

    def str_endpoints
      @str_endpoints
    end

    def regexp_endpoints
      @regexp_endpoints
    end

  end
end

def api_endpoints(&block)
  Blockenspiel.invoke(block, Fission::ApiBuilder.instance)
end

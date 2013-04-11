Array(Fission::Config[:apis]).each do |api|
  require "fission/apis/#{api}"
end

module Fission
  class Api
    include Celluloid
    
    def initialize
      @str_endpoints, @regexp_endpoints = ApiBuilder.instance.endpoints
    end

    def process(*args)
      process_str_endpoints(*args) || process_regexp_endpoints(*args)
    end

    def process_str_endpoints(type, string, request, connection)
      if(@str_endpoints[type])
        @str_endpoints[type].each do |k,v|
          if(k == string)
            v.call(request, connection)
            return true
          end
        end
      end
      false
    end

    def process_regexp_endpoints(type, string, request, connection)
      if(@regexp_endpoints[type])
        @regexp_endpoints[type].each do |k,v|
          unless(res = string.scan(k).empty?)
            if(res.first.is_a?(Array))
              v.call(request, connection, res)
            else
              v.call(request, connection)
            end
            return true
          end
        end
      end
      false
    end
  end
end

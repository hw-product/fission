module Fission
  class Worker::Webhook < Reel::Server
    include Celluloid::Logger

    def initialize(host, port)
      Actor[:transport].register(:webhook, current_actor)
      @object_storage = Actor[:transport].fetch(:object_storage)
      info "Webhook server started on #{host}:#{port}"
      @api = Fission::Api.new
      super(host, port, &method(:on_connection))
    end

    def on_connection(connection)
      while request = connection.request
        info "Request: #{request.method} - #{request.url}"
        unless(@api.process(request.method.to_s.downcase.to_sym, request.url, request, connection))
          connection.respond(:not_found, 'Page not found!')
        end
      end
    end
  end
end

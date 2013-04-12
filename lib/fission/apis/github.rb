require 'fission/api_builder'
require 'multi_json'

api_endpoints do
  include Celluloid::Logger

  post '/github-build' do |request, connection|
    begin
      payload = MultiJson.load(request.body)
    rescue MultiJson::DecodeError => e
      info "Error parsing request body: #{e}"
    end

    if payload
      Celluloid::Actor[:transport][:object_storage].cache_payload_to_disk(
        origin: :github,
        repository_url: payload['repository']['url'],
        repository_owner: payload['repository']['owner'],
        target_commit: payload['after'],
        reference: payload['ref']
      )
      connection.respond :ok, 'Payload received and added to queue'
    else
      connection.respond :bad_request, 'Bad Request: No JSON data detected'
    end
  end

  get '/test' do |request, connection|
    puts request.body
    puts request.headers
    connection.respond :ok
  end
end

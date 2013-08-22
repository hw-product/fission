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
      Celluloid::Actor[:transport][:package_builder].route_package_payload(
        origin: :github,
        fission: {
          account: 'spox'
        },
        repository_url: payload['repository']['url'],
        repository_name: payload['repository']['name'],
        repository_owner_name: payload['repository']['owner']['name'],
        repository_owner_email: payload['repository']['owner']['email'],
        repository_private: payload['repository']['private'] == 1,
        target_commit: payload['after'],
        reference: payload['ref'],
        payload: payload
      )
      connection.respond :ok, 'Payload received and added to queue'
    else
      connection.respond :bad_request, 'Bad Request: No JSON data detected'
    end
  end

  post '/test' do |request, connection|
    puts request.body
    puts request.headers
    connection.respond :ok, 'Thanks!'
  end
end

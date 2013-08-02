require 'fission/api_builder'
require 'multi_json'

api_endpoints do
  include Celluloid::Logger

  post '/github' do |request, connection|
    begin
      form_data = URI.decode_www_form(request.body)
      payload = MultiJson.load(form_data[0][1])
    rescue MultiJson::DecodeError => e
      info "Error parsing request body: #{e}"
    end

    if payload
      Celluloid::Actor[:transport][:test_runner].route_test_payload(
        origin: :github,
        repository_url: payload['repository']['url'],
        repository_name: payload['repository']['name'],
        repository_owner_name: payload['repository']['owner']['name'],
        repository_owner_email: payload['repository']['owner']['email'],
        repository_private: payload['repository']['private'],
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
    connection.respond :ok, request.body
  end
end

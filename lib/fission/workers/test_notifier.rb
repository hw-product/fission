module Fission
  class Worker::TestNotifier < Worker

    def initialize
      Actor[:transport].register :test_notifier, current_actor
      info 'Test Notifier initialized'
    end

    def format_irc_message results
      passed, failed = results.partition { |r| r[:passed] }
      message = []
      message << "Fission TK"
      message << "Failed: " + failed.map { |r| r[:name] }.join(', ') unless failed.empty?
      message << "Passed: " + passed.map { |r| r[:name] }.join(', ') unless passed.empty?
      message.join(' :: ')
    end

    def notify_irc_channel irc, results
      message = format_irc_message(results)
      Timeout::timeout(10) do
        CarrierPigeon.send(irc.merge(message: message))
      end
    rescue => error
      warn(notify_irc_channel: error.message)
    end

    def terminate
    end

  end
end

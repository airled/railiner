module Slack_message

  require 'curb'

  def send_message(message, status)
    payload = {'color' => status, 'fields' => [{'value' => message}]}.to_json
    Curl.post(ENV["PARSER_HOOK"], payload)
  end

end

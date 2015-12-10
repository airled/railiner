require 'curb'

class Slack_message

  def send(message, status)
    payload = {'color' => status, 'fields' => [{'value' => message}]}.to_json
    Curl.post(ENV["PARSER_HOOK"], payload)
  end

end

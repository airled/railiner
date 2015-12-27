require_relative '../slack_message'

Slack_message.new.send("New version deployed on #{Time.now}", 'warning')

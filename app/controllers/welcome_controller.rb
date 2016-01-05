class WelcomeController < ApplicationController

  def index
    time = Group.last.created_at
    @date = [time.day, time.month, time.year].map { |t| t.to_s.rjust(2, '0') }.join('.')
  end
  
end

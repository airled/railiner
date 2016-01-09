class WelcomeController < ApplicationController

  def index
    @date = 
      if Group.exists?
        time = Group.last.created_at
        [time.day, time.month, time.year].map { |t| t.to_s.rjust(2, '0') }.join('.')
      end || nil
  end
  
end

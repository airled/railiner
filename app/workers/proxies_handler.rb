class Proxies_handler

  include Sidekiq::Worker
  sidekiq_options :queue => :proxies

  def perform(ip)
  end


end
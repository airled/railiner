class Proxies_getter

  include Sidekiq::Worker
  sidekiq_options :queue => :proxy_source

  def perform(url)
    html = Nokogiri::HTML(Curl.get(url).body)
    html.xpath('//tr/td[1]/font[@class="spy14"]').map do |ip|
      Proxies_handler.perform_async(ip.text)
    end
  end

end

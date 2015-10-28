class Proxies_getter

  include Sidekiq::Worker
  sidekiq_options :queue => :proxy_source

  def perform(url)
    html = Nokogiri::HTML(Curl.get(url).body)
    list = html.xpath('//body/table[2]/tbody/tr[4]/td/table/tbody/tr/td[1]/font[@class="spy14"]').map { |node| node.text }
    list.map do |address|
      Proxies_handler.perform_async(address)
    end
  end

end

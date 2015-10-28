class Proxies_getter

  include Sidekiq::Worker
  sidekiq_options :queue => :proxy_source

  def perform(url)
    html = Nokogiri::HTML(Curl.get(url).body)
    html.xpath('//td[1]/font').map do |node|
      Proxies_handler.perform_async(node.text) if node.text.scan(/[А-Яа-я]/).empty?
    end
  end

end

class Proxies_getter

  include Sidekiq::Worker
  sidekiq_options :queue => :proxy_source

  def perform(url)
    html = Nokogiri::HTML(Curl.get(url).body)
    list = html.xpath('//td[1]/font').map do |node|
      node.text if node.text.scan(/[А-Яа-я]/).empty?
    end
  end

end

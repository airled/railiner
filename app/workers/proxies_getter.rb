class Proxies_getter

  include Sidekiq::Worker
  sidekiq_options :queue => :getter

  def perform(url, redis_proxies)
    html = Nokogiri::HTML(Curl.get(url).body)
    list = html.xpath('//td[1]/font').map do |node|
      node.text if node.text.scan(/[А-Яа-я]/).empty?
    end
    redis_proxies.set("ips", list).to_json
  end

end

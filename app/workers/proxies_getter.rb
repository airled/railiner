class Proxies_getter

  include Sidekiq::Worker
  sidekiq_options queue: :getter

  def perform(url)
    loop do
      html = Nokogiri::HTML(Curl.get(url).body)
      list = html.xpath('//td[1]/font').map do |node|
        node.text if node.text.scan(/[А-Яа-я]/).empty?
      end
      Redis.new.set("ip_list", list.compact.to_json)
      sleep(1800)
    end
  end

end

require 'nokogiri'
require 'curb'
# class Proxies_getter

#   include Sidekiq::Worker
#   sidekiq_options :queue => :proxy_source

#   def perform(url)
    url = 'http://xseo.in/freeproxy'
    html = Nokogiri::HTML(Curl.get(url).body)
    list = html.xpath('//td[1]/font').map do |node|
      # Proxies_handler.perform_async(ip.text)
      node.text if node.text.scan(/[А-Яа-я]/).empty?
    end
    p list.compact
  # end

# end

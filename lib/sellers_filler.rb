require 'nokogiri'
require 'curb'

max_id = Costs.maximum(:seller_id)
1.upto(max_id) do |seller_id|
  print "\rcurrent id: #{seller_id}"
  html = Nokogiri::HTML(Curl.get("#{seller_id}.shop.onliner.by").body)
  name = html.xpath('//h1[@class="sells-title"]').text
  Seller.create(id: seller_id, name: name) if name != ''
end
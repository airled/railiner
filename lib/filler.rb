require 'nokogiri'
require 'curb'

1.upto(15000) do |seller_id|
  html = Nokogiri::HTML(Curl.get("#{seller_id}.shop.onliner.by").body)
  name = html.xpath('//h1[@class="sells-title"]').text.force_encoding("UTF-8")
  Seller.create(onliner_id: seller_id, name: name) if name != ''
end
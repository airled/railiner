require 'nokogiri'
require 'curb'

class Filler

  def self.run
    sellers_ids = Cost.select(:seller_id).distinct.map(&:seller_id)
    sellers_ids.sort.map do |seller_id|
      print "\rcurrent id: #{seller_id}"
      html = Nokogiri::HTML(Curl.get("#{seller_id}.shop.onliner.by").body)
      name = html.xpath('//h1[@class="sells-title"]').text
      Seller.create(id: seller_id, name: name) if name != ''
    end
  end

end

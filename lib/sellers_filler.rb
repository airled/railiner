require 'nokogiri'
require 'curb'

class Filler

  def self.run
    sellers_ids = Cost.select(:seller_id).distinct.map(&:seller_id)
    amount = sellers_ids.size
    sellers_ids.sort.map.with_index do |seller_id, index|
      print "\rcurrent id: #{seller_id} - #{index + 1}/#{amount}"
      loop do
        html = Nokogiri::HTML(Curl.get("#{seller_id}.shop.onliner.by").body)
        if (!html.text.include?('503 Service Temporarily Unavailable'))
          name = html.xpath('//h1[@class="sells-title"]').text.strip
          Seller.create(id: seller_id, name: name) if name != ''
          break
        end #if
      end #loop
    end #map
    puts "\nSellers filled."
  end #def

end

require 'nokogiri'
require 'curb'

#Filler resolves seller's id and save its name in the database
class Filler

  def self.run
    sellers_ids = Cost.select(:seller_id).distinct.map(&:seller_id)
    amount = sellers_ids.size
    sellers_ids.sort.map.with_index do |seller_id, index|
      loop do
        html = Nokogiri::HTML(Curl.get("#{seller_id}.shop.onliner.by").body)
        unless html.text.include?('503 Service Temporarily Unavailable')
          name = html.xpath('//h1[@class="sells-title"]').text.strip
          Seller.create(id: seller_id, name: name) if name != ''
          break
        end #unless
      end #loop
      print "\rFilled: #{(100 * index.next) / amount}%"
    end #map
    puts "\r#{Seller.count} sellers filled."
  end #def

end

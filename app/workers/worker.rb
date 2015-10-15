class Worker

  include Sidekiq::Worker

  def perform(product_url, product)
    loop do
      html = Nokogiri::HTML(Curl.get(product_url + '/prices#region=minsk&currency=byr').body)
      if (!html.text.include?('503 Service Temporarily Unavailable'))
        rows = html.xpath('//div[@id="region-minsk"]/div[@class="b-offers-list-line-table"]/table[@class="b-offers-list-line-table__table"]/tbody[@class="js-position-wrapper"]/tr')
        rows.map do |row|
          price = row.xpath('./td[1]//a').text.strip
          seller_id = row.xpath('./@data-shop').text.strip
          product.costs.create(seller_id: seller_id, price: price)
        end
        break
      end
    end
  end

end

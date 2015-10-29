class Prices_handler

  include Sidekiq::Worker
  sidekiq_options :queue => :handler

  def perform(product_url, id)
    loop do
      ips = JSON.parse(redis_proxies.get("ips"))
      proxy_ip = ips[rand(ips.size)]

      prices_url = product_url + '/prices#region=minsk&currency=byr'
      
      html = Nokogiri::HTML(proxy_request(prices_url, proxy_ip).body)
      unless (html.text.include?('503 Service Temporarily Unavailable') || html.text.include?('403 Forbidden'))
        rows = html.xpath('//div[@id="region-minsk"]/div[@class="b-offers-list-line-table"]/table[@class="b-offers-list-line-table__table"]/tbody[@class="js-position-wrapper"]/tr')
        rows.map do |row|
          price = row.xpath('./td[1]//a').text.strip
          seller_id = row.xpath('./@data-shop').text.strip
          product = Product.find_by(id: id)
          product.costs.create(seller_id: seller_id, price: price)
        end
        break
      end
    end
  end

  def proxy_request(prices_url, proxy_ip)
    proxy_request = Curl::Easy.new(prices_url) do |curl|
      curl.proxy_url = proxy_ip
    end
    proxy_request.perform
    proxy_request.body
  end

end


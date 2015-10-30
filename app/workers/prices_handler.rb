class Prices_handler

  include Sidekiq::Worker
  sidekiq_options :queue => :handler

  def proxy_request(prices_url, proxy_ip)
    proxy_request = Curl::Easy.new(prices_url) { |curl| curl.proxy_url = proxy_ip }
    proxy_request.perform
    proxy_request.body
  end

  def perform(product_url, id)
    loop do
      list = JSON.parse(Redis.new.get("ip_list"))
      proxy_ip = list[rand(ips.size)]
      prices_url = product_url + '/prices#region=minsk&currency=byr'
      html = Nokogiri::HTML(proxy_request(prices_url, proxy_ip))

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

    end #loop
  end #def

end


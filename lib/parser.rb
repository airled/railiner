require 'nokogiri'
require 'open-uri'
require 'json'
require 'curb'
require 'cgi'

class Parser

  URL = 'http://catalog.onliner.by/'

  def run
    start = current_stats
    html = get_html(URL) 
    group_nodes = []
    categories_nodes = []
    html.xpath('//h2[@class="catalog-navigation-list__group-title"]').map { |group_node| group_nodes << group_node }
    html.xpath('//ul[@class="catalog-navigation-list__links"]').map { |categories_node| categories_nodes << categories_node }
    group_nodes.zip(categories_nodes).map do |group_node, categories_node|
      db_group = create_group(group_node.text)
      categories_node.xpath('./li/span[@class="catalog-navigation-list__link-inner"]').map do |node|
        category_name = node.xpath('./a/@href').text.sub(URL,'').split('/').first.split('?').first
        db_category = create_group_category(db_group, node, category_name)
        products_request_url = 'https://catalog.api.onliner.by/search/' + category_name
        pages_quantity = JSON.parse(curl_request(products_request_url))['page']['last'].to_i
        parse_pages(category_name, pages_quantity, products_request_url, db_category)
      end
    end
    stop = current_stats
    results(stop, start)
  end #def

  def get_html(source)
    puts 'Getting HTML...'
    Nokogiri::HTML(open(source))
  end

  def translate_to_en(word)
    string = CGI::escape "#{word}"
    html = Nokogiri::HTML(open("http://gogo.by/translate/?from=ru&query=#{string}&to=en"))
    html.xpath('//div[@id="result"]').text
  end

  def create_group(name_ru)
    Group.create(name: translate_to_en(name_ru).gsub(/[\ ,]/, '_').downcase, name_ru: name_ru)
  end

  def create_group_category(group, node, name)
    url = node.xpath('./a/@href').text
    name_ru = node.xpath('./a/@title').text
    group.categories.create(url: url, name_ru: name_ru, name: name)
  end
  
  def curl_request(url)
    user_agents = ['Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:39.0) Gecko/20100101 Firefox/39.0', 'Mozilla/5.0 (Windows NT 6.1; rv:35.0) Gecko/20100101 Firefox/35.0', 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.155 Safari/537.36']
    data = Curl.get(url) do |http| 
      http.headers["User-Agent"] = user_agents[rand(user_agents.size)]
    end
    data.perform
    data.body_str
  end
  
  def parse_pages(category_name, quantity, url, db_category)
    puts "...#{category_name}/#{quantity} pages"
    1.upto(quantity) do |page_number|
      begin
        get_products_from_page(url + '?page=' + page_number.to_s, db_category)
        sleep(0.5)
      rescue => exception
        # puts 'Disconnected. Retrying...'
        exception.message
        sleep(5)
        redo
      end
    end
  end

  def get_products_from_page(page_url, category)
    json = curl_request(page_url)
    JSON.parse(json)['products'].map do |product|
      name = product['full_name']
      url = product['html_url']
      image_url = product['images']['icon']
      description = product['description']
      if product['prices'].nil?
        min_price = 'N/A'
        max_price = 'N/A'
      else
        min_price = product['prices']['min'].to_s.reverse.scan(/\d{1,3}/).join(' ').reverse
        max_price = product['prices']['max'].to_s.reverse.scan(/\d{1,3}/).join(' ').reverse
      end
      category.products.create(name: name, url: url, image_url: image_url, max_price: max_price, min_price: min_price, description: description)
    end
  end

  def current_stats
    {time: Time.new, groups: Group.count, categories: Category.count, products: Product.count}
  end

  def results(stop, start)
    secs_total = (stop[:time] - start[:time]).to_i
    hours = secs_total / 3600
    mins = (secs_total - hours * 3600) / 60
    secs = secs_total - hours * 3600 - mins * 60
    groups_delta = stop[:groups] - start[:groups]
    categories_delta = stop[:categories] - start[:categories]
    products_delta = stop[:products] - start[:products]
    puts "Done in #{hours}:#{mins}:#{secs}"
    puts "Got: #{groups_delta} groups, #{categories_delta} categories, #{products_delta} products"
  end

end

Parser.new.run

require 'nokogiri'
require 'json'
require 'curb'
require 'erb'

class Parser

  URL = 'http://catalog.onliner.by/'

  def run
    start = stats
    html = get_html(URL) 
    group_nodes = html.xpath('//h2[@class="catalog-navigation-list__group-title"]').map { |group_node| group_node }
    categories_nodes = html.xpath('//ul[@class="catalog-navigation-list__links"]').map { |categories_node| categories_node }
    group_nodes.zip(categories_nodes).map do |group_node, categories_node|
      db_group = create_group(group_node.text)
      categories_node.xpath('./li/span[@class="catalog-navigation-list__link-inner"]').map do |node|
        category_name = node.xpath('./a/@href').text.sub(URL,'').split('/').first.split('?').first
        db_category = create_group_category(db_group, node, category_name)
        parse_category_pages(category_name, db_category, group_node.text)
        sleep(2)
      end
    end
    stop = stats
    results(stop, start)
  end #def

  def get_html(source)
    Nokogiri::HTML(Curl.get(source).body)
  end

  def translate_to_en(word)
    encoded = ERB::Util.url_encode(word)
    url = "http://gogo.by/translate/?from=ru&query=#{encoded}&to=en"
    get_html(url).xpath('//div[@id="result"]').text
  end

  def create_group(name_ru)
    name = translate_to_en(name_ru).gsub(/[\ ,]/, '_').downcase
    Group.create(name: name, name_ru: name_ru)
  end

  def create_group_category(group, node, name)
    url = node.xpath('./a/@href').text
    name_ru = node.xpath('./a/@title').text
    group.categories.create(url: url, name_ru: name_ru, name: name)
  end
  
  def special_request(url)
    user_agents = ['Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:39.0) Gecko/20100101 Firefox/39.0', 'Mozilla/5.0 (Windows NT 6.1; rv:35.0) Gecko/20100101 Firefox/35.0', 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.155 Safari/537.36']
    data = Curl.get(url) do |http| 
      http.ssl_verify_peer = false
      http.headers["User-Agent"] = user_agents[rand(user_agents.size)]
    end
    data.perform
    data.body_str
  end
  
  def parse_category_pages(category_name, db_category, group_name)
    products_request_url = 'https://catalog.api.onliner.by/search/' + category_name
    json = special_request(products_request_url)
    quantity = JSON.parse(json)['page']['last'].to_i
    1.upto(quantity) do |page_number|
      puts "#{group_name}/#{category_name} : #{page_number}/#{quantity}"
      begin
        page_url = products_request_url + '?page=' + page_number.to_s
        get_products_from_page(page_url, db_category)
        sleep(0.5)
      rescue => exception
        puts exception.message
        sleep(5)
        redo
      end
    end
  end

  def get_products_from_page(page_url, category)
    json = special_request(page_url)
    JSON.parse(json)['products'].map do |product|
      name = product['full_name']
      url = product['html_url']
      image_url = product['images']['icon']
      description = Nokogiri::HTML.parse(product['description']).text
      if product['prices'].nil?
        min_price = max_price = 'N/A'
      else
        min_price = product['prices']['min'].to_s.reverse.scan(/\d{1,3}/).join(' ').reverse
        max_price = product['prices']['max'].to_s.reverse.scan(/\d{1,3}/).join(' ').reverse
      end
      category.products.create(name: name, url: url, image_url: image_url, max_price: max_price, min_price: min_price, description: description)
    end
  end

  def stats
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

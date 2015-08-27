require 'nokogiri'
require 'open-uri'
require 'json'
require 'curb'

class Parser

  URL = 'http://catalog.onliner.by/'

  def run
    start_time = Time.new
    html = get_html(URL) 
    group_nodes = []
    categories_nodes = []
    html.xpath('//h2[@class="catalog-navigation-list__group-title"]').map { |group_node| group_nodes << group_node }
    html.xpath('//ul[@class="catalog-navigation-list__links"]').map { |categories_node| categories_nodes << categories_node }
    group_nodes.zip(categories_nodes).map do |group_node, categories_node|
      db_group = create_group(group_node.text)
      categories_node.xpath('./li/span[@class="catalog-navigation-list__link-inner"]').map do |node|
        category_name = node.xpath('./a/@href').text.sub(URL,'').split('?').first
        db_category = create_group_category(db_group, node, category_name)
        products_request_url = 'https://catalog.api.onliner.by/search/' + category_name
        pages_quantity = JSON.parse(curl_request(products_request_url))['page']['last'].to_i
        puts "...#{category_name}/#{pages_quantity} pages"
        1.upto(pages_quantity) do |page_number|
          begin
            get_products_from_page(products_request_url + '?page=' + page_number.to_s, db_category)
            sleep(0.5)
          rescue
            puts 'Disconnected. Retrying...'
            sleep(5)
            redo
          end
        end
        sleep(5)
      end
    end
    stop_time = Time.new
    results(stop_time, start_time)
  end #def

  def get_html(source)
    puts 'Getting HTML...'
    Nokogiri::HTML(open(source))
  end

  def create_group(name_ru)
    Group.create(name_ru: name_ru)
  end

  def create_group_category(group, node, name)
    url = node.xpath('./a/@href').text
    name_ru = node.xpath('./a/@title').text
    group.categories.create(url: url, name_ru: name_ru, name: name)
  end
  
  def curl_request(url)
    user_agents = ['Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:39.0) Gecko/20100101 Firefox/39.0', 'Mozilla/5.0 (Windows NT 6.1; rv:35.0) Gecko/20100101 Firefox/35.0', 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.155 Safari/537.36']
    data = Curl::Easy.new(url) do |http| 
      http.headers["User-Agent"] = user_agents[rand(user_agents.size)]
    end
    data.perform
    data.body_str
  end
  
  def get_products_from_page(url, category)
    json = curl_request(url)
    JSON.parse(json)['products'].map do |product|
      name = product['full_name']
      url = product['html_url']
      image_url = product['images']['icon']
      category.products.create(name: name, url: url, image_url: image_url)
    end
  end
  
  def results(stop, start)
    secs_total = (stop - start).to_i
    hours = secs_total / 3600
    mins = (secs_total - hours * 3600) / 60
    secs = secs_total - hours * 3600 - mins * 60
    puts "Done in #{hours}:#{mins}:#{secs}"
    # puts "Got: #{Group.count} groups, #{Category.count} categories, #{Product.count} products"
  end

end

Parser.new.run

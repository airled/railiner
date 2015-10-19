require 'nokogiri'
require 'json'
require 'curb'
require 'erb'

class Parser

  URL = 'http://catalog.onliner.by/'

  def run
    begin
      start = stats
      html = get_html(URL) 
      group_nodes = html.xpath('//h2[@class="catalog-navigation-list__group-title"]')
      categories_nodes = html.xpath('//ul[@class="catalog-navigation-list__links"]')
      group_nodes.zip(categories_nodes).map do |group_node, categories_node|
        db_group = create_group(group_node.text.strip)
        categories_node.xpath('./li/span[@class="catalog-navigation-list__link-inner"]').map do |category_node|
          db_category = create_group_category(db_group, category_node)
          parse_category_pages(db_category, group_node.text)
          sleep(2)
        end
      end
      stop = stats
      results(stop, start)
    rescue => exception
      puts exception.message
      slack_results(exception.message)
    end
  end #def

  private

  def get_html(source)
    Nokogiri::HTML(Curl.get(source).body)
  end

  def translate_to_en(word)
    encoded = ERB::Util.url_encode(word)
    url = "http://gogo.by/translate/?from=ru&query=#{encoded}&to=en"
    get_html(url).xpath('//div[@id="result"]').text
  end

  def create_group(name_ru)
    name = translate_to_en(name_ru).gsub(/[\ ,]/, '_').downcase.strip
    Group.create(name: name, name_ru: name_ru)
  end

  def create_group_category(group, category_node)
    url = category_node.xpath('./a/@href').text.strip
    name = url.sub(URL,'').split('/').first.split('?').first.strip
    name_ru = category_node.xpath('./a/@title').text.strip
    group.categories.create(url: url, name_ru: name_ru, name: name)
  end
  
  def special_request(url)
    user_agents = ['Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:39.0) Gecko/20100101 Firefox/39.0',
                   'Mozilla/5.0 (Windows NT 6.1; rv:35.0) Gecko/20100101 Firefox/35.0',
                   'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.155 Safari/537.36']
    data = Curl.get(url) do |http| 
      http.ssl_verify_peer = false
      http.headers["User-Agent"] = user_agents[rand(user_agents.size)]
    end
    data.perform
    data.body_str
  end
  
  def parse_category_pages(db_category, group_name)
    products_request_url = 'https://catalog.api.onliner.by/search/' + db_category.name
    json = special_request(products_request_url)
    quantity = JSON.parse(json)['page']['last'].to_i
    1.upto(quantity) do |page_number|
      print "\r#{group_name}/#{db_category.name} : #{page_number}/#{quantity}"
      page_url = products_request_url + '?page=' + page_number.to_s
      get_products_from_page(page_url, db_category)
    end
    puts
  end

  def get_products_from_page(page_url, category)
    loop do
      page = special_request(page_url)
      if (!page.include?('503 Service Temporarily Unavailable'))
        JSON.parse(page)['products'].map do |product|
          name = product['full_name'].strip
          url = product['html_url'].strip
          image_url = (product['images']['icon'].nil?) ? product['images']['header'].strip : product['images']['icon'].strip
          description = Nokogiri::HTML.parse(product['description']).text.strip
          if product['prices'].nil?
            min_price = max_price = 'N/A'
          else
            min_price = product['prices']['min'].to_s.reverse.scan(/\d{1,3}/).join(' ').reverse.strip
            max_price = product['prices']['max'].to_s.reverse.scan(/\d{1,3}/).join(' ').reverse.strip
          end
          db_product = category.products.create(name: name, url: url, image_url: image_url, max_price: max_price, min_price: min_price, description: description)
          Worker.perform_async(url, db_product.id) if min_price != 'N/A'
        end
        break
      else
        puts "\nBanned! Waiting 5s..."
        sleep(5)
      end #if
    end #loop
  end #def

  def stats
    {time: Time.new, groups: Group.count, categories: Category.count, products: Product.count}
  end

  def results(stop, start)
    seconds = (stop[:time] - start[:time]).to_i
    time_delta = [seconds / 3600, seconds / 60 % 60, seconds % 60].map { |t| t.to_s.rjust(2,'0') }.join(':')
    groups_delta = stop[:groups] - start[:groups]
    categories_delta = stop[:categories] - start[:categories]
    products_delta = stop[:products] - start[:products]
    time_result = "Done in #{time_delta}"
    db_result = "Got: #{groups_delta} groups, #{categories_delta} categories, #{products_delta} products"
    puts "#{time_result}\n#{db_result}"
    slack_results(time_result + '. ' + db_result)
  end

  def slack_results(result)
    payload = {'text' => result}.to_json
    Curl.post(ENV["PARSER_HOOK"], payload)
  end

end

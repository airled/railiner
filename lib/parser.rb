require 'nokogiri'
require 'json'
require 'curb'
require 'erb'
require_relative './product_comparator'
require_relative './slack_message'

#main script for saving groups of categories, categories of products and products in database
class Parser

  URL = 'http://catalog.onliner.by/'

  def run(as_daemon, with_queue)
    begin
      # clear_sidekiq
      Process.daemon if as_daemon
      File.open("#{File.expand_path('../../tmp/pids', __FILE__)}/parser.pid", 'w') { |f| f << Process.pid }
      Slack_message.new.send("#{Time.now} : started by #{ENV['USER']}@#{ENV['HOSTNAME']}", 'warning')
      start_stats = stats_now
      Proxies_getter.perform_async('http://xseo.in/freeproxy') if with_queue
      html = get_html(URL)
      group_nodes = html.xpath('//h2[@class="catalog-navigation-list__group-title"]')
      categories_nodes = html.xpath('//ul[@class="catalog-navigation-list__links"]')
      group_nodes.zip(categories_nodes).map do |group_node, categories_node|
        group_name_ru = group_node.text.strip
        db_group = create_group(group_name_ru)
        categories_node.xpath('./li/span[@class="catalog-navigation-list__link-inner"]').map do |category_node|
          category_url = category_node.xpath('./a/@href').text.strip
          if Category.find_by(url: category_url).nil?
            db_category = create_group_category(db_group, category_node)
            parse_category_pages(db_category, group_name_ru, with_queue)
            db_category.update(products_quantity: db_category.products.count)
            sleep(2)
          else
            create_group_category(db_group, category_node)
          end #if
        end #map cat_nodes
      end #zip map
      stop_stats = stats_now
      results(start_stats, stop_stats)
    rescue => exception
      puts exception.message
      Slack_message.new.send("#{Time.now} : #{exception.message}", 'danger')
    end
  end #def

  private

  def clear_sidekiq
    Sidekiq.redis { |c| c.del('stat:processed') }
    Sidekiq.redis { |c| c.del('stat:failed') }
  end

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
    name_ru = category_node.xpath('./a/@title').text.strip
    name = url.sub(URL,'').split('/').first.split('?').first.strip
    group.categories.create(url: url, name_ru: name_ru, name: name)
  end
  
  def special_request(url)
    user_agents = [
      'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:39.0) Gecko/20100101 Firefox/39.0',
      'Mozilla/5.0 (Windows NT 6.1; rv:35.0) Gecko/20100101 Firefox/35.0',
      'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.155 Safari/537.36',
      'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:41.0) Gecko/20100101 Firefox/41.0'
    ]
    data = Curl.get(url) do |http| 
      http.ssl_verify_peer = false
      http.headers["User-Agent"] = user_agents[rand(user_agents.size)]
    end
    data.perform
    data.body_str
  end
  
  #fetch all products from all the pages of one category
  def parse_category_pages(db_category, group_name_ru, with_queue)
    products_request_url = 'https://catalog.api.onliner.by/search/' + db_category.name
    json = special_request(products_request_url)
    quantity = JSON.parse(json)['page']['last'].to_i
    1.upto(quantity) do |page_number|
      print "\r#{group_name_ru}/#{db_category.name} : #{page_number}/#{quantity}"
      page_url = products_request_url + '?page=' + page_number.to_s
      get_products_from_page(page_url, db_category, with_queue)
    end
    puts
  end

  #fetch all products from one page and save it in the database
  def get_products_from_page(page_url, category, with_queue)
    loop do
      page = special_request(page_url)
      if (!page.include?('503 Service Temporarily Unavailable'))
        JSON.parse(page)['products'].map do |product|
          Comparator.new.run(category, product, with_queue, page_url)
        end
        break
      else
        puts "\nBanned! Waiting 5s..."
        sleep(5)
      end #if
    end #loop
  end #def
  
  def stats_now
    [Time.new, Group.count, Category.count, Product.count]
  end

  def results(start_stats, stop_stats)
    deltas = stop_stats.zip(start_stats).map { |pair| (pair[0] - pair[1]).to_i }
    time = [deltas[0] / 3600, deltas[0] / 60 % 60, deltas[0] % 60].map { |t| t.to_s.rjust(2, '0') }.join(':')
    time_result = "Done in #{time}"
    db_result = "Got: #{deltas[1]} groups, #{deltas[2]} categories, #{deltas[3]} products"
    puts "#{time_result}\n#{db_result}"
    Slack_message.new.send("#{Time.now} : #{time_result}. #{db_result}", 'good')
  end

end
